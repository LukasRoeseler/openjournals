# Read TOPfactor.org Data -------------------------------------------------

topfactor <- read.csv("https://osf.io/qatkz/download/")
topfactor$issn <- gsub("-", "", topfactor$Issn)

# table(topfactor$Replication.score, useNA = "always")
# table(topfactor$Replication.score > 0, useNA = "always")

# psych::alpha(cbind(topfactor$Data.citation.score
#                    , topfactor$Analysis.code.transparency.score
#                    , topfactor$Replication.score
#                    , topfactor$Data.citation.score
#                    , topfactor$Open.science.badges.score
#                    , topfactor$Data.transparency.score
#                    , topfactor$Study.preregistration.score
#                    , topfactor$Materials.transparency.score
#                    , topfactor$Analysis.plan.preregistration.score
#                    , topfactor$Registered.reports...publication.bias.score
#                    , topfactor$Design...analysis.reporting.guidelines.score
# ))