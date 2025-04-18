# Read TOPfactor.org Data -------------------------------------------------
# library(ggplot2)
# library(ggpubr)


topfactor <- read.csv("https://osf.io/qatkz/download/")
topfactor$issn_merge <- gsub("-", "", topfactor$Issn)



# table(topfactor$Replication.score, useNA = "always")
# table(topfactor$Replication.score > 0, useNA = "always")

# psych::alpha(cbind(topfactor$Data.citation.score
#                    , topfactor$Analysis.code.transparency.score
#                    , topfactor$Replication.score
#                    , topfactor$Open.science.badges.score
#                    , topfactor$Data.transparency.score
#                    , topfactor$Study.preregistration.score
#                    , topfactor$Materials.transparency.score
#                    , topfactor$Analysis.plan.preregistration.score
#                    , topfactor$Registered.reports...publication.bias.score
#                    , topfactor$Design...analysis.reporting.guidelines.score
# ))


# 
# # Plot Topfactor Levels ---------------------------------------------------
# 
# topfactortable <- (cbind(topfactor$Data.citation.score
#                        , topfactor$Analysis.code.transparency.score
#                        , topfactor$Replication.score
#                        , topfactor$Open.science.badges.score
#                        , topfactor$Data.transparency.score
#                        , topfactor$Study.preregistration.score
#                        , topfactor$Materials.transparency.score
#                        , topfactor$Analysis.plan.preregistration.score
#                        , topfactor$Registered.reports...publication.bias.score
#                        , topfactor$Design...analysis.reporting.guidelines.score
# ))
# 
# topranks <- data.frame("top" = c("Data.citation.score"
#                                  , "Analysis.code.transparency.score"
#                                  , "Replication.score"
#                                  , "Open.science.badges.score"
#                                  , "Data.transparency.score"
#                                  , "Study.preregistration.score"
#                                  , "Materials.transparency.score"
#                                  , "Analysis.plan.preregistration.score"
#                                  , "Registered.reports...publication.bias.score"
#                                  , "Design...analysis.reporting.guidelines.score")
#                        , "adoption" = colSums(topfactortable>0, na.rm = TRUE)/nrow(topfactortable)
#                        , "adoption2" = colSums(topfactortable>1, na.rm = TRUE)/nrow(topfactortable)
#                        , "adoption3" = colSums(topfactortable>2, na.rm = TRUE)/nrow(topfactortable)
# )
# 
# topranks$top <- substr(topranks$top, 0, nchar(topranks$top)-6)
# 
# t1 <- ggplot(topranks, aes(x = adoption, y = reorder(top, adoption))) + geom_bar(stat = "identity", col = "black", fill = "grey") + xlab("Proportion of Journals with Score > 0") + ylab("TOP Criterion") +
#   theme_bw() + xlim(c(0, 1))
# 
# t2 <- ggplot(topranks, aes(x = adoption2, y = reorder(top, adoption))) + geom_bar(stat = "identity", col = "black", fill = "grey") + xlab("Proportion of Journals with Score > 1") + ylab("TOP Criterion") +
#   theme_bw() + xlim(c(0, 1))
# 
# t3 <- ggplot(topranks, aes(x = adoption3, y = reorder(top, adoption))) + geom_bar(stat = "identity", col = "black", fill = "grey") + xlab("Proportion of Journals with Score > 2") + ylab("TOP Criterion") +
#   theme_bw() + xlim(c(0, 1))
# 
# ggarrange(t1, t2, t3, nrow = 1, labels = c("Level 1 or higher", "Level 2 or higher", "Level 3"))
