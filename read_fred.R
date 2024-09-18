# FORRT Replication Database ----------------------------------------------



# 
# # Open processed dataset
# red_link <- "https://osf.io/mkvq2/download/" # Version that was used until 2023-10-02; file will not be updated
# # If you want to expand upon this code, please consider using the most recent version: https://osf.io/z5u9b
# red <- read.csv(red_link)
# n_red <- nrow(red) # save number of rows for descriptives that will be computed later
# 
# write.csv(red, file = "prestige_fred_data.csv") # save unprocessed data
# 
# # exclude all cases that do not report that a replication was successful or an informative failure (inconclusive and practical failure will not be considered)
# red <- red[!is.na(red$result), ]
# red <- red[(red$result == "success") | (red$result == "informative failure to replicate"), ]
# 
# # journals
# fredjournals <- unique(red$orig_journal)
# 
# journal_input <- NULL
# journal_output <- NULL
# issn <- NULL
# 
# for (j in fredjournals) {
#   x <- rcrossref::cr_journals(query = j)
#   
#   journal_input <- c(journal_input, j)
#   journal_output <- c(journal_output, x$data$title)
#   issn <- c(issn, x$data$issn)
#   Sys.sleep(1)
#   print(length(journal_input))
# }
# 
# fred_j <- data.frame(journal_input, journal_output, issn)
# 
# 
# 
# # 
# # x <- rcrossref::cr_works(doi = red$doi_original[1])
# # x$data$publisher
# # x$data$short.container.title
# # x$data$issn
# # 
# # j <- rcrossref::cr_journals(issn = x$data$issn)


# jlist <- fred_j$issn
# sjr_journals_fred <- sjr_journals[sjr_journals$issn_short %in% jlist,]