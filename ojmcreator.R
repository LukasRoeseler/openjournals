# OJM (Open Journal Master) Creation --------------------------------------
# This script reads individual datasets and creates the OJM from these


# 1. Setup & Packages -----------------------------------------------------

list.of.packages <- c("ggplot2", "psych", "devtools", "openxlsx", 
                      "RCurl", "markdown", "dplyr", "tidyr", "stringr", "httr", "readr")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

# Load packages
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(psych)
library(openxlsx)
library(httr)
library(readr)


# 2. TOP Factors ----------------------------------------------------------
cat("Processing TOP Factors...\n")

topfactor <- read.csv("https://osf.io/qatkz/download/") %>%
  mutate(
    issn_merge = str_remove_all(Issn, "-"),
    # Convert empty strings to proper NAs to prevent bad merges
    issn_merge = na_if(trimws(issn_merge), ""), 
    journal_name_top = tolower(trimws(Journal))
  ) %>%
  rename(top_factor_score = Total) %>%
  # Deduplicate by ISSN and Name (ensures we don't accidentally delete multiple journals that just lack an ISSN)
  distinct(issn_merge, journal_name_top, .keep_all = TRUE)


# 3. FLoRA ----------------------------------------------------------------
cat("Processing FLoRA...\n")

flora <- read.csv("https://raw.githubusercontent.com/forrtproject/FReD-data/refs/heads/main/output/flora.csv", 
                  stringsAsFactors = FALSE, na.strings = c("", "NA")) %>%
  filter(!is.na(journal_o) & journal_o != "", !is.na(type)) %>%
  mutate(
    type = tools::toTitleCase(tolower(trimws(type))),
    outcome = tools::toTitleCase(tolower(trimws(outcome))),
    extracted_issn = str_extract(bibtex_ref_o, "(?i)ISSN=\\{([^}]+)\\}"),
    extracted_issn = str_remove_all(extracted_issn, "(?i)ISSN=\\{|\\}")
  ) %>%
  group_by(journal_o) %>%
  mutate(issn = first(na.omit(extracted_issn))) %>%
  ungroup() %>%
  mutate(
    issn_merge = str_remove_all(issn, "-"),
    issn_merge = na_if(trimws(issn_merge), ""),
    journal_name_flora = tolower(trimws(journal_o))
  ) %>%
  count(journal_name_flora, issn_merge, type, outcome, name = "count") %>%
  pivot_wider(
    names_from = c(type, outcome),
    values_from = count,
    names_sep = "_",
    values_fill = list(count = 0)
  ) %>%
  mutate(flora_total_studies = rowSums(across(where(is.numeric)))) %>%
  # Group by Name here instead of ISSN so journals without ISSNs don't get squashed together
  group_by(journal_name_flora) %>%
  slice_max(order_by = flora_total_studies, n = 1, with_ties = FALSE) %>%
  ungroup()


# 4. Retraction Watch Database --------------------------------------------
cat("Processing Retraction Watch...\n")

rwdb <- read.csv("https://gitlab.com/crossref/retraction-watch-data/-/raw/main/retraction_watch.csv?ref_type=heads")

rwdb_clean <- rwdb %>%
  mutate(journal_name_rwdb = tolower(trimws(Journal))) %>%
  group_by(journal_name_rwdb) %>%
  summarise(rwdb_retraction_count = n(), .groups = "drop")


# 5. Hijacked Journals Checker (HJC) --------------------------------------
cat("Processing Hijacked Journals...\n")

if(file.exists("Data/Retraction Watch Hijacked Journals Checker 2026-03-13.xlsx")) {
  hjc <- openxlsx::read.xlsx("Data/Retraction Watch Hijacked Journals Checker 2026-03-13.xlsx", startRow = 2)
  
  hjc_clean <- hjc %>%
    mutate(
      issn_merge = str_remove_all(`ISSN.(Original)`, "-"),
      issn_merge = na_if(trimws(issn_merge), ""),
      issn_merge = na_if(issn_merge, "NA"), # Extra check in case gsub created literal "NA" text
      journal_name_hjc = tolower(trimws(`Original.journal`)),
      is_hijacked = TRUE
    ) %>%
    distinct(issn_merge, journal_name_hjc, .keep_all = TRUE)
} else {
  warning("HJC Excel file not found. Creating empty HJC dataframe to prevent script from breaking.")
  hjc_clean <- data.frame(issn_merge = character(), journal_name_hjc = character(), is_hijacked = logical())
}


# 6. DOAJ -----------------------------------------------------------------
cat("Processing DOAJ...\n")

# Read from your local file
doaj_meta <- read_csv("Data/journalcsv__doaj_20260313_1326_utf8.csv", show_col_types = FALSE)

doaj_clean <- doaj_meta %>%
  select(
    title = `Journal title`,
    issn_print = `Journal ISSN (print version)`,
    issn_electronic = `Journal EISSN (online version)`,
    apc = APC,
    apc_amount = `APC amount`,
    review_process = `Review process`,
    plagiarism_screening = `Journal plagiarism screening policy`
  ) %>%
  mutate(
    issn_merge = coalesce(issn_print, issn_electronic),
    issn_merge = str_remove_all(issn_merge, "-"),
    issn_merge = as.character(issn_merge),
    journal_name_doaj = tolower(trimws(title)),
    doaj_oa_model = case_when(
      apc == "Yes" ~ "gold",
      apc == "No" ~ "diamond",
      TRUE ~ "unknown"
    )
  ) %>%
  filter(!is.na(issn_merge)) %>%
  distinct(issn_merge, .keep_all = TRUE)


# 7. Merge Master Database (OJM) ------------------------------------------
cat("Merging all databases into OJM...\n")

# Step 1: Combine all datasets using full_join. 
# na_matches = "never" prevents R from mashing missing ISSNs together!
ojm <- doaj_clean %>%
  full_join(topfactor, by = "issn_merge", na_matches = "never") %>%
  full_join(flora, by = "issn_merge", na_matches = "never") %>%
  full_join(hjc_clean, by = "issn_merge", na_matches = "never")

# Step 2: Create a single unified Journal Name column
ojm <- ojm %>%
  mutate(
    master_journal_name = coalesce(
      journal_name_doaj, 
      journal_name_top,
      journal_name_flora,
      journal_name_hjc
    ),
    # If a journal didn't come from the hijacked list, make it explicitly FALSE instead of NA
    is_hijacked = replace_na(is_hijacked, FALSE) 
  )

# Step 3: Join Retraction Watch (which only has Names, no ISSN)
ojm <- ojm %>%
  left_join(rwdb_clean, by = c("master_journal_name" = "journal_name_rwdb"), na_matches = "never") %>%
  mutate(rwdb_retraction_count = replace_na(rwdb_retraction_count, 0))


# 8. Clean up and Save ----------------------------------------------------

# Reorder columns to put important identifiers first, followed by your requested DOAJ variables
ojm <- ojm %>%
  relocate(issn_merge, master_journal_name, rwdb_retraction_count, top_factor_score, doaj_oa_model, 
           is_hijacked, review_process, apc, apc_amount, plagiarism_screening)

write.csv(ojm, file = "Data/ojmdb.csv", row.names = FALSE)
cat("Done! Master database saved as 'ojmdb.csv'.\n")
