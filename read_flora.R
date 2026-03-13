library(dplyr)
library(tidyr)
library(stringr)

# 1. Load Data
df <- read.csv("https://raw.githubusercontent.com/forrtproject/FReD-data/refs/heads/main/output/flora.csv", stringsAsFactors = FALSE, na.strings = c("", "NA"))

# 2. Process data and compute counts
journal_summary <- df %>%
  # Filter out empty journals and missing types
  filter(!is.na(journal_o) & journal_o != "", !is.na(type)) %>%
  
  # Standardize text variables
  mutate(
    type = tools::toTitleCase(tolower(trimws(type))),
    outcome = tools::toTitleCase(tolower(trimws(outcome))),
    
    # Extract ISSN from the BibTeX column
    extracted_issn = str_extract(bibtex_ref_o, "(?i)ISSN=\\{([^}]+)\\}"),
    extracted_issn = str_remove_all(extracted_issn, "(?i)ISSN=\\{|\\}")
  ) %>%
  
  # Group by journal to assign the found ISSN to all rows of that journal
  group_by(journal_o) %>%
  mutate(issn = first(na.omit(extracted_issn))) %>%
  ungroup() %>%
  
  # ---> HIER ENTSTEHT DIE NEUE VARIABLE <---
  mutate(
    issn_merge = str_remove_all(issn, "-"),     # Entfernt den Bindestrich (z.B. 1099-0771 -> 10990771)
    issn_merge = replace_na(issn_merge, "")     # Ersetzt NA durch "" (leerer String)
  ) %>%
  
  # Count the occurrences (including the new variables)
  count(journal_o, issn, issn_merge, type, outcome, name = "count") %>%
  
  # Pivot into a wide format
  pivot_wider(
    names_from = c(type, outcome),
    values_from = count,
    names_sep = "_",
    values_fill = list(count = 0)
  ) %>%
  
  # Calculate total number of studies per journal
  mutate(Total_Studies = rowSums(across(where(is.numeric)))) %>%
  
  # Sort by highest total volume
  arrange(desc(Total_Studies)) %>%
  
  # Reorder columns for a clean look
  relocate(journal_o, issn, issn_merge, Total_Studies)

# View the result
head(journal_summary)


flora <- journal_summary


# Scimago Journal Rank ----------------------------------------------------


sjr_raw_url <- "https://github.com/ikashnitsky/sjrdata/raw/refs/heads/master/data/sjr_journals.rda"
download.file(sjr_raw_url,"sjr_data")
load("sjr_data")



# use first ISSN only
sjr_journals$issn_short <- substr(sjr_journals$issn, 1, 8) # use first part of ISSNs only

sjr_journals$issn_merge <- sjr_journals$issn_short 



