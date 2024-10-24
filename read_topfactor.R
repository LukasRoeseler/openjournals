# Read TOPfactor.org Data -------------------------------------------------
library(ggplot2)


topfactor <- read.csv("https://osf.io/qatkz/download/")
topfactor$issn <- gsub("-", "", topfactor$Issn)

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



# Plot Topfactor Levels ---------------------------------------------------

topfactortable <- (cbind(topfactor$Data.citation.score
                       , topfactor$Analysis.code.transparency.score
                       , topfactor$Replication.score
                       , topfactor$Open.science.badges.score
                       , topfactor$Data.transparency.score
                       , topfactor$Study.preregistration.score
                       , topfactor$Materials.transparency.score
                       , topfactor$Analysis.plan.preregistration.score
                       , topfactor$Registered.reports...publication.bias.score
                       , topfactor$Design...analysis.reporting.guidelines.score
))

topranks <- data.frame("top" = c("Data.citation.score"
                                 , "Analysis.code.transparency.score"
                                 , "Replication.score"
                                 , "Open.science.badges.score"
                                 , "Data.transparency.score"
                                 , "Study.preregistration.score"
                                 , "Materials.transparency.score"
                                 , "Analysis.plan.preregistration.score"
                                 , "Registered.reports...publication.bias.score"
                                 , "Design...analysis.reporting.guidelines.score")
                       , "adoption" = colSums(topfactortable>0, na.rm = TRUE)/nrow(topfactortable)
)

topranks$top <- substr(topranks$top, 0, nchar(topranks$top)-6)

ggplot(topranks, aes(x = adoption, y = top)) + geom_bar(stat = "identity", col = "black", fill = "grey") + xlab("Proportion of Journals with Score > 0") + ylab("TOP Criterion") +
  theme_bw() + xlim(c(0, 1))
