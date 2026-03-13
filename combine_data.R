


# Datasets ----------------------------------------------------------------
topfactor$issn_merge
flora$issn_merge
sjr_journals$issn_merge


# SJR + TOP ---------------------------------------------------------------
oj <- base::merge(sjr_journals, topfactor, by = "issn_merge"
                  # , all.x = all
                  # , all.y = all
                  )
oj <- oj[oj$year == 2023, ]#
# make it so that journals that do not have both variables are not omitted
names(oj)[52] <- "top_factor"



# + FLoRA -----------------------------------------------------------------
# oj <- base::merge(oj, flora, by = "issn_merge", all.x = TRUE, all.y = FALSE)



write.csv(oj, file = paste(Sys.Date(), "ojdb.csv", sep = "_"))
