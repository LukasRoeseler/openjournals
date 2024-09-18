# SJR + TOP ---------------------------------------------------------------
st <- merge(sjr_journals, topfactor, by.y = "issn", by.x = "issn_short")
st <- st[st$year == 2023, ]
# st <- st[st$region == "Western Europe" | st$region == "Northern America", ]
# cbind(st$issn, st$issn_short)