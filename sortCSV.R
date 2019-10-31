#sort CSV based on columns

library(tidyverse)

iDir <- "C:/Users/John Mutua/Dropbox"
oDir <- "C:/Users/John Mutua/Dropbox/weather_data"

fLS = list.files(path=iDir, pattern="*.csv", full.names=TRUE)

for (f in fLS){
  
  f_name <- gsub(".*Dropbox/", "", f)
  
  data <- read_csv(f)
  
  #data <- select(data,-c(X1))
  
  data <- data %>%
    
    arrange(SITE_ID, YEAR, MONTH, DAY, LONG, LAT, CL_VARIABLE, LAYER_NAME, VALUE)
    
  write_csv(data, paste0(oDir, "/", f_name))
  
  cat(paste0('Re-arranged ', f_name,'\n'))
  
}

