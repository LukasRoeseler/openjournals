

# For the script to run, you need to download the sjr data from Kashnitsky's github: https://github.com/ikashnitsky/sjrdata/blob/master/data/sjr_journals.rda # 2023 version


# Read ScimagoJR Journal Data ---------------------------------------------
load(file = "Data/sjr_journals.rda") # https://github.com/ikashnitsky/sjrdata/blob/master/data/sjr_journals.rda

# use first ISSN only
sjr_journals$issn_short <- substr(sjr_journals$issn, 1, 8) # use first part of ISSNs only






# # install
# devtools::install_github("ikashnitsky/sjrdata", force = TRUE)
# 
# # load
# library(sjrdata)
# 
# # use
# View(sjr_countries)







