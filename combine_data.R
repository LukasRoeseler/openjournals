# SJR + TOP ---------------------------------------------------------------
oj <- merge(sjr_journals, topfactor, by = "issn_merge")
oj <- oj[oj$year == 2023, ]#
# make it so that journals that do not have both variables are not omitted

