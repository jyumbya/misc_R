## Set libraries
library(raster)

# set variables 
mthLs <- c(paste0("0",1:9), 10:12)

## Write raster files
iDir <- "D:/Trash/rh"
oDir <- "D:/Trash/rh/out"

##Average relative humidity calculation
rh_am <- stack(paste0(iDir, "/CM10_1975H_RHam", mthLs, "_V1.2.tif"))
rh_pm <- stack(paste0(iDir, "/CM10_1975H_RHpm", mthLs, "_V1.2.tif"))

rh <- (rh_am + rh_pm)/2

for (i in 1:nlayers(rh)){
  
  writeRaster(rh[[i]], paste0(oDir, "/rh_",i, ".tif"), 
              format="GTiff", overwrite=T, datatype='INT2S')
  
}
