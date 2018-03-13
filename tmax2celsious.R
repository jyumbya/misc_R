## Set libraries
library(raster)

# set variables 
mthLs <- c(paste0("0",1:9), 10:12)

## Write raster files
cDir <- "D:/OneDrive - CGIAR/ToBackup/Projects/Livestock and Environment Flagship/Heat_stress_mapping/data/climate_data/current_new"

##Average relative humidity calculation
tmax <- stack(paste0(cDir, "/tmax_", mthLs, ".tif"))


tmax <- tmax/10

for (i in 1:nlayers(tmax)){
  
  writeRaster(tmax[[i]], paste0(cDir, "/c_trash/tmax_",i, ".tif"), 
              format="GTiff", overwrite=T, datatype='INT2S')
  
}