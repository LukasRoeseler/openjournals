# OJM (Open Journal Master) Creation --------------------------------------
# This script reads individual datasets and creates the OJM from these

# 1. Setup & Packages -----------------------------------------------------
list.of.packages <- c("ggplot2", "psych", "devtools", "openxlsx", 
                      "RCurl", "markdown", "dplyr", "tidyr", "stringr", "httr", "readr")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

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
    issn_merge = na_if(trimws(issn_merge), ""), 
    journal_name_top = tolower(trimws(Journal))
  ) %>%
  rename(top_factor_score = Total) %>%
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
      issn_merge = na_if(issn_merge, "NA"),
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


# 7. SCImago Journal Rank (SJR) -------------------------------------------
cat("Processing SJR...\n")

sjr_raw_url <- "https://github.com/ikashnitsky/sjrdata/raw/refs/heads/master/data/sjr_journals.rda"
download.file(sjr_raw_url, "sjr_data", mode = "wb") 
load("sjr_data")

sjr_clean <- sjr_journals %>%
  filter(year == max(year, na.rm = TRUE)) %>%
  mutate(
    issn_merge = substr(str_remove_all(issn, "-"), 1, 8),
    issn_merge = na_if(trimws(issn_merge), ""),
    journal_name_sjr = tolower(trimws(title))
  ) %>%
  # Added 'total_docs_3years' and 'areas' as requested
  select(issn_merge, journal_name_sjr, sjr, h_index, total_docs_3years, areas, categories) %>%
  filter(!is.na(issn_merge)) %>%
  distinct(issn_merge, journal_name_sjr, .keep_all = TRUE)


# 8. The Nordic List ------------------------------------------------------
cat("Processing Nordic List...\n")

nlj <- read.csv2("Data/2026-03-13 Scientific Journals and Series.csv", check.names = FALSE)

nlj_clean <- nlj %>%
  mutate(
    # Combine print and online ISSN, prioritize print
    issn_merge = coalesce(na_if(trimws(`Print ISSN`), ""), na_if(trimws(`Online ISSN`), "")),
    issn_merge = str_remove_all(issn_merge, "-"),
    issn_merge = na_if(trimws(issn_merge), ""),
    journal_name_nlj = tolower(trimws(`Original Title`))
  ) %>%
  select(issn_merge, journal_name_nlj, nlj_level_2025 = `Level 2025`, nlj_level_2024 = `Level 2024`) %>%
  filter(!is.na(issn_merge)) %>%
  distinct(issn_merge, journal_name_nlj, .keep_all = TRUE)


# 9. Merge Master Database (OJM) ------------------------------------------
cat("Merging all databases into OJM...\n")

ojm <- doaj_clean %>%
  full_join(topfactor, by = "issn_merge", na_matches = "never") %>%
  full_join(flora, by = "issn_merge", na_matches = "never") %>%
  full_join(hjc_clean, by = "issn_merge", na_matches = "never") %>%
  full_join(sjr_clean, by = "issn_merge", na_matches = "never") %>%
  full_join(nlj_clean, by = "issn_merge", na_matches = "never")

ojm <- ojm %>%
  mutate(
    master_journal_name = coalesce(
      journal_name_doaj, 
      journal_name_top,
      journal_name_flora,
      journal_name_hjc,
      journal_name_sjr,
      journal_name_nlj
    ),
    is_hijacked = replace_na(is_hijacked, FALSE) 
  )

ojm <- ojm %>%
  left_join(rwdb_clean, by = c("master_journal_name" = "journal_name_rwdb"), na_matches = "never") %>%
  mutate(rwdb_retraction_count = replace_na(rwdb_retraction_count, 0))


# 10. Clean up and Save ---------------------------------------------------

# Reorder columns: Added total_docs_3years, areas, and categories to the list
ojm <- ojm %>%
  relocate(issn_merge, master_journal_name, rwdb_retraction_count, top_factor_score, doaj_oa_model, 
           is_hijacked, sjr, h_index, total_docs_3years, areas, categories, 
           nlj_level_2025, review_process, apc, apc_amount, plagiarism_screening)

write.csv(ojm, file = "Data/ojmdb.csv", row.names = FALSE)
cat("Done! Master database saved as 'Data/ojmdb.csv'.\n")