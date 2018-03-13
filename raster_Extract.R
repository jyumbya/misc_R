library(rgdal)
library(raster)

cDir <- "F:/Data/Global/Worldclim/wc2.0_30s"
p = readOGR(dsn="D:/OneDrive - CGIAR/ToBackup/Scientist requests/Kelvin_Shikuku", layer="GPScoordinates_shikuku_23112017")

ras <- list.files(paste0(cDir), pattern = '.tif$',full.names = T)

ras.s <- stack(ras)
ext <- extract(ras.s,p)

rownames(ext)<-p@data$hhid

write.csv(ext, file = "D:/OneDrive - CGIAR/ToBackup/Scientist requests/Kelvin_Shikuku/climate_data.csv", row.names=TRUE)

