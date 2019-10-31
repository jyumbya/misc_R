#sort CSV based on columns

library(tidyverse)

iDir <- "C:/Users/John Mutua/Dropbox/raw_data"
oDir <- "C:/Users/John Mutua/Dropbox"

dirLS <- list.dirs(paste0(iDir, "/"), recursive = FALSE, full.names = FALSE)

for (dir in dirLS){
  
  fLS = list.files(paste0(iDir, "/", dir), pattern="*.csv", full.names=TRUE)
  
  for (f in fLS){
    
    f_name <- gsub(paste0(".*", dir, "/"), "", f)
    
    f_name <- gsub(".csv.*", "", f_name)
    
    #data <- read_csv(f)
    
    data <- read_csv("C:/Users/John Mutua/Dropbox/raw_data/ea_NASA_1981_2010.csv")
    
    data <- select(data,-c(X))
    
    #data <- select(data, SITE_ID, LONG, LAT, CL_VARIABLE, LAYER_NAME, YEAR, MONTH, DAY, VALUE)
    
    data <- select(data, site_id, LON, LAT, YEAR, MM, DD, DOY, YYYYMMDD, RH2M, T2M_MAX)
    
    data <- data %>%
      
      arrange(site_id, YEAR, MM, DD, LON, LAT)
    
    stationLS <- unique(data$site_id)
    
    data_split<- subset(data, site_id %in% stationLS[81:169])
    
    write_csv(data_split, paste0(oDir, "/ea_NASA_1981_2010", "_81-169", ".csv"))

  }
  
}





