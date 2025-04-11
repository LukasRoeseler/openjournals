# SJR + TOP ---------------------------------------------------------------
oj <- base::merge(sjr_journals, topfactor, by = "issn_merge"
                  # , all.x = all
                  # , all.y = all
                  )
oj <- oj[oj$year == 2023, ]#
# make it so that journals that do not have both variables are not omitted

names(oj)[52] <- "top_factor"

write.csv(oj, file = paste(Sys.Date(), "ojdb.csv", sep = "_"))
