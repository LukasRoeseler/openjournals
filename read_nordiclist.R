
# Read Data from Nordic List (journals) -----------------------------------
nlj_link <- "https://kanalregister.hkdir.no/publiseringskanaler/AlltidFerskListeTidsskrift2SomCsv"
nlj <- read.csv2(nlj_link) # nordic list journals

names(nlj) <- c("journal_id", "Original Title", "International Title", "Print ISSN", "Online ISSN", "Open Access", "Publishing Agreement", "NPI Academic Discipline", "NPI Scientific Field", "Level 2025", "Level 2024", "Level 2023", "Level 2022", "Level 2021", "Level 2020", "Level 2019", "Level 2018", "Level 2017", "Level 2016", "Level 2015", "Level 2014", "Level 2013", "Level 2012", "Level 2011", "Level 2010", "Level 2009", "Level 2008", "Level 2007", "Level 2006", "Level 2005", "Level 2004", "publisher_id", "Publishing Company", "Publisher", "Country of Publication", "Language", "Conference Proceedings", "Series", "Established", "Ceased", "URL", "Last Updated")

table(nlj$`Level 2024`, useNA = "always")
hist(as.numeric(nlj$`Level 2024`))
