#read STATA files and write to excel

#load libraries
library(haven)
library(xlsx)

#input variables
iDir <- "D:/OneDrive - CGIAR/ToBackup/Projects/Food systems mapping/data/survey"

#read .dta for version 13 and 14
d <- read_stata(paste0(iDir, "/", "Fao consumer survey.dta"))

#write to excel
write.xlsx(d, "D:/OneDrive - CGIAR/ToBackup/Projects/Food systems mapping/data/survey/Fao consumer survey.xlsx")
