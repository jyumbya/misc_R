library(rjson)
library(sp)
library(GSIF)
library(rgdal)

## define location
pnts <- data.frame(lon=c(37.437971), lat=c(-1.866980), id=c("Matwiku"))
coordinates(pnts) <- ~lon+lat
proj4string(pnts) <- CRS("+proj=longlat +datum=WGS84")

#obtain values from grids 
soilgrids.r <- REST.SoilGrids(c("ORCDRC"))
ov <- over(soilgrids.r, pnts)

write_csv(ov, "soil_extract.csv")
