library(data.table)
library(tidyverse)
library(nasapower)
library(chirps)

iDir <- "D:/OneDrive - CGIAR/Scientist requests/Job_Kihara/data_extraction" 

# csv file must have a latitude and longitude column
sites_raw <- read_csv(paste0(iDir, "/MetaAnalysis_Matched_ed_clean.csv"))

sites <- as.data.frame(sites_raw)

dat <- na.omit(dat)

ltn <- list()

# NASA POWER

for(i in 1:nrow(sites)){
  
  site_row<- sites[i,]
  
  # confirm temporal average and parameters to extract from API
  ltn[[i]] <- get_power(community = "AG",
                        lonlat = c(site_row$lon, site_row$lat),
                        pars = c("T2M", "PRECTOT"),
                        dates = c("2008-01-01", "2018-12-31"),
                        temporal_average = "DAILY")
  
  site_id = site_row$ID 
  
  ltn[[i]]$site_id <- site_id
  
  cat(paste0('Pulled Site ',i,' of ', nrow(sites),'\n'))
  
}

# for chirps
for(i in 1:nrow(sites)){
  
  site_row<- sites[i,]
  
  lonlat <- select(site_row, new_lon, new_lat)
  
  dates = c("2008-01-01", "2018-03-31")
  
  ltn[[i]] <- get_chirps(lonlat, dates)
  
  site_id = site_row$ID 
  
  ltn[[i]]$site_id <- site_id
  
  cat(paste0('Pulled Site ',i,' of ', nrow(sites),'\n'))
  
}

data <- rbindlist(ltn)

write_csv(data, paste0(iDir, "/", "MetaAnalysis_Matched_ed_weather_data.csv"))