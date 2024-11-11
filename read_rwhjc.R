# Read Retraction Watch Hijacked Journal Checker

link <- "https://docs.google.com/uc?id=1ak985WGOgGbJRJbZFanoktAN_UFeExpE&export=download&hl=en_US"

hj <- openxlsx::read.xlsx(link, startRow = 2)
