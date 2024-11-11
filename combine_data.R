# SJR + TOP ---------------------------------------------------------------
oj <- merge(sjr_journals, topfactor, by = "issn_merge")
oj <- oj[oj$year == 2023, ]

# st <- st[st$region == "Western Europe" | st$region == "Northern America", ]
# cbind(st$issn, st$issn_short)