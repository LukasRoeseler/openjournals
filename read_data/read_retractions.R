
# Read Retractionwatch Database -------------------------------------------
rwdb_link <- "https://gitlab.com/crossref/retraction-watch-data/-/raw/main/retraction_watch.csv?ref_type=heads&inline=false"

retractions <- read.csv(rwdb_link)
