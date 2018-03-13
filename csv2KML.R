library(rgdal)
library(plotKML)

setwd("D:/OneDrive - CGIAR/ToBackup/Projects/GIZ_CSS/Western_Kenya_soil_sampling")

# read in data
d <- read.csv('./WesternKenya_soil_sampling_FINAL.csv', header=TRUE)

# make shapefiles
xy <- d[,c(3,2)]
d <- SpatialPointsDataFrame(coords = xy, data = d, proj4string = CRS("+proj=longlat +datum=WGS84"))
d <- spTransform(d, CRS('+proj=utm +zone=33 +south +datum=WGS84'))

# create KML file
kml(d, file.name = "WesternKenya_soil_sampling_FINAL.kml", colour_scale=rep("#FFFF00", 2), points_names="")

