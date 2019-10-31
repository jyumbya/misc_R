#merge two csvs

library(tidyverse)

iDir <- "C:/Users/John Mutua/Dropbox/raw_data"
oDir <- "C:/Users/John Mutua/Dropbox"

dirLS <- list.dirs(paste0(iDir, "/"), recursive = FALSE, full.names = FALSE)

for (dir in dirLS){
  
  fLS = list.files(paste0(iDir, "/", dir), pattern="*.csv", full.names=TRUE)
  
  new_data1 <- read_csv(fLS[1])
  new_data2 <- read_csv(fLS[2])
  
  new_data3 <- merge(new_data1, new_data2, by="SITE_ID")
  

  new_data3 <- full_join(new_data1, new_data2, by = SITE_ID)
  
  new_data <- Reduce(rbind, lapply(fLS, read.csv))
  
  #f_name <- gsub(".*Dropbox/", "", f)
  
  f_name <- gsub(paste0(".*", dir, "/"), "", fLS)
  
  f_name <- f_name[1]
  
  f_name <- sub("_s.*", "", f_name)
  
  write_csv(new_data, paste0(oDir, "/", f_name, ".csv"))
  
}


