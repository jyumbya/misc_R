library(rjson)
library(sp)
library(xlsx)
library(GSIF)
library(rgdal)

setwd("D:/OneDrive - CGIAR/ToBackup/Scientist requests/Nepo")

pnts = readOGR(dsn=".", layer="rwanda_nepo_sites")

# ## define location
# pnts <- data.frame(lon=c(74.5056), lat=c(19.1897), id=c("Kutewadi"))
# coordinates(pnts) <- ~lon+lat
# proj4string(pnts) <- CRS("+proj=longlat +datum=WGS84")
# pnts

#obtain values from grids 
soilgrids.r <- REST.SoilGrids(c("ORCDRC", "PHIHOX","SNDPPT","SLTPPT","CLYPPT", "BLD", "CEC", "BDT", "TAXNWRB"))
ov <- over(soilgrids.r, pnts)
str(ov)

write.xlsx(ov, "D:/OneDrive - CGIAR/ToBackup/Scientist requests/Nepo/nepo_soils.xlsx")
