library(data.table)
library(tidyverse)
library(nasapower)
library(aWhereAPI)

iDir <- "D:/OneDrive - CGIAR/Scientist requests/Job_Kihara/data_extraction" 

sites_raw <- read_csv(paste0(iDir, "/MetaAnalysis_Matched_ed_clean.csv"))

sites <- as.data.frame(sites_raw)

ltn <- list()

#aWhere

for(i in 1:nrow(sites)){

  site_row<- sites[i,]

  aWhereAPI::get_token(uid = "7GjmVZ95yFNTpJGnl6Ex00inqEI4UgA2", secret = "iUSwHpoH1zPxHMNu") #your uid and secret here

  year_start <- 2008
  year_end <- 2018
  monthday_start <- "01-01" 
  monthday_end <- "12-31"
  
  ltn[[i]] <- weather_norms_latlng(latitude = site_row$Lat,
                                   longitude = site_row$Lon,
                                   monthday_start = monthday_start,
                                   monthday_end = monthday_end,
                                   year_start = year_start,
                                   year_end = year_end,
                                   properties = c("meanTemp", "precipitation")) 
  
  site_id = site_row$ID
  ltn[[i]]$site_id <- site_id

}

# NASA POWER

for(i in 1:nrow(sites)){
  
  site_row<- sites[i,]
  
  ltn[[i]] <- get_power(community = "AG",
                             lonlat = c(site_row$new_lon, site_row$lat),
                             pars = c("T2M", "PRECTOT"),
                             temporal_average = "CLIMATOLOGY")
  
  site_id = site_row$ID 
  
  ltn[[i]]$site_id <- site_id
  
  cat(paste0('Pulled Site ',i,' of ', nrow(sites),'\n'))
  
}

data <- rbindlist(ltn)

write_csv(data, paste0(iDir, "/", "MetaAnalysis_Matched_ed_weather_data.csv"))