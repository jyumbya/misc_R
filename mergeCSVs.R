#merge two csvs

library(tidyverse)

iDir <- "C:/Users/John Mutua/Downloads/ea_weather_stations_1-80 and 81_169"
oDir <- "C:/Users/John Mutua/Dropbox/"

fLS = list.files(path=iDir, pattern="*.csv", full.names=TRUE)

new_data <- Reduce(rbind, lapply(fLS, read.csv))

write_csv(new_data, paste0(oDir, "/", "ea_NASA_1981_2010.csv"))
