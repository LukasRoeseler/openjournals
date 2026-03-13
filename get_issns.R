flora <- openxlsx::read.xlsx("libre2.xlsx")

journals <- unique(flora$journal_o)

library(rcrossref)
result <- rcrossref::cr_journals(issn = NULL, query = journals[1]) # 0888-4080
result$data$issn

result <- rcrossref::cr_journals(issn = NULL, query = journals[70]) # 0888-4080

table(flora$outcome)


sort(table(flora$journal_r, useNA = "always"), decreasing = TRUE)


flora_nonmeta <- flora[flora$metapaper_r == 0, ]
sort(table(flora_nonmeta$journal_r, useNA = "always"), decreasing = TRUE)
