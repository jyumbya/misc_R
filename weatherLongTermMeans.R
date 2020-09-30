library(data.table)
library(tidyverse)
library(rgdal)
library(aWhereAPI)


iDir <- "D:/OneDrive - CGIAR/Scientist requests/Job_Kihara/data_extraction" 

data_raw <- read_csv(paste0(iDir, "/MetaAnalysis_Formatted_clean.csv"))

# data_raw <- data_raw %>% 
#   
#   select(ID_Micro, Lat, Lon)

# data_raw <- na.omit(data_raw)

data_raw$Lat <- as.numeric(data_raw$Lat)

data_raw$Lon <- as.numeric(data_raw$Lon)

# data_raw <- na.omit(data_raw)


# write_csv(data_raw, paste0(iDir, "/", "MetaAnalysis_Formatted_new.csv"))

data_raw <- data_raw[!duplicated(data_raw$ID_Micro),]


# xy <- data_raw[,c(3,2)]
# 
# pts <- SpatialPointsDataFrame(coords = xy, 
#                               data = data_raw, 
#                               proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))


# 
# 
# library(rworldmap)
# newmap <- getMap(resolution = "low")
# plot(newmap)
# 
# plot(pts, add=TRUE, color = 'red')

 
daily_ag <- list()


for(i in 70:nrow(data_raw)){

  site<- data_raw[i,]

  aWhereAPI::get_token(uid = "7GjmVZ95yFNTpJGnl6Ex00inqEI4UgA2", secret = "iUSwHpoH1zPxHMNu") #your uid and secret here

  obs_startdate <- as.character("2008-01-01")
  obs_enddate <- as.character("2018-01-31")

  daily_ag[[i]] <- aWhereAPI::daily_observed_latlng(latitude = site$Lat,
                                                    longitude = site$Lon,
                                                    day_start = obs_startdate,
                                                    day_end = obs_enddate,
                                                    properties = c("precipitation", "temperatures"))

  site_ID_Micro = site$ID_Micro
  daily_ag[[i]]$ID_Micro <- site_ID_Micro
  
  cat(paste0('Pulled Site ',i,' of ', nrow(data_raw),'\n'))

}

data <- rbindlist(daily_ag)

yr <- substr(data$date, 1, 4)
mth <- substr(data$date, 6, 7)
dy <- substr(data$date, 9,10)

data$year <- yr
data$day <- dy
data$month <- mth

data$average_temperature <- (data$temperatures.min + data$temperatures.max)/2

data_new <- data %>%

  group_by(ID_Micro, year, latitude, longitude) %>%

  summarise(annual_precipitation = sum(precipitation.amount, na.rm = TRUE), mean_temperature = mean(average_temperature, na.rm = TRUE))


write_csv(data_new, paste0(iDir, "/", "MetaAnalysis_Formatted_weather_data.csv"))

save.image(file=paste0(iDir, '/MetaAnalysis_Formatted_clean.RData'))
