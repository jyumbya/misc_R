# Precipitation Effectiveness Index (PEI) equation based on Thornthwaite (1931)
# Author John Mutua, CIAT
# Last modified: 28/9/2017

# clear your work space
rm(list = ls(all = TRUE))

# # install packages
# install.packages("raster")
# install.packages("sp")

# load packages
require(raster)
require(sp)

# set variables
cDir <- "D:/CGIAR/Da Silva, Mayesse Aparecida (CIAT) - Digital Soil Mapping Training India 2017/Digital Soil Mapping Training India 2017 shared with people/Data/Warvandi_control"
oDir <- "D:/CGIAR/Da Silva, Mayesse Aparecida (CIAT) - Digital Soil Mapping Training India 2017/Digital Soil Mapping Training India 2017 shared with people/Data/Warvandi_control"
varList <- c("prec", "tmax", "tmin")
res <- "30s"
mthLs <- c(paste0("0",1:9), 10:12)

# create temporary and output folder
if(!dir.exists(paste0(oDir, '/temp', sep=''))) {dir.create(paste0(oDir, '/temp', sep=''))}
if(!dir.exists(paste0(oDir, '/output', sep=''))) {dir.create(paste0(oDir, '/output', sep=''))}

# read all rasters
for (var in varList){
  rs.stk <- stack(paste0(cDir, "/climate_data/wc2.0_", res, "_", var, "_", mthLs, ".tif"))
  
  # take into account the following
  if (var != "prec"){
    rs.stk <- rs.stk * 1.8+32 # temperature at fahranheit
  } else {
    rs.stk <- rs.stk * 0.0394 # precipitation in inches
  }
  
  # write separate files
  for (i in 1:nlayers(rs.stk)){
    writeRaster(rs.stk[[i]], paste0(oDir, "/temp/", var, "_", i, ".tif"), format="GTiff", overwrite=T)
  }
}

# calculate average temperature
tmax <- stack(paste0(oDir, "/temp/tmax_", 1:12, ".tif"))
tmin <- stack(paste0(oDir, "/temp/tmin_", 1:12, ".tif"))
tmean <- (tmax + tmin)/2
for (i in 1:nlayers(tmean)){
  writeRaster(tmean[[i]], paste0(oDir, "/temp/tmean_", i, ".tif"), format="GTiff", overwrite=T)
}

# calculate monthly PEI
for (i in 1:12) {
  preci = raster(paste0(oDir, "/temp/prec_", i, ".tif", sep = ""))
  tmean = raster(paste0(oDir, "/temp/tmean_", i, ".tif", sep = ""))
  pei = ((preci/(tmean-10))^1.111) * 11.5 
  writeRaster (pei, paste0(oDir, "/output/pei_month_", i, ".tif", sep = ""), overwrite=T)
}

# calculate annual PEI 
pei.stack <- stack(list.files(paste0(oDir, "/output"), pattern = '*.tif$', full.names = T))
pei.sum <- sum(pei.stack)
writeRaster(pei.sum, paste0(oDir, "/output/pei_annual"), format="GTiff", overwrite=T)

# remove temp folder
unlink(paste0(oDir, '/temp', sep=''), recursive=TRUE)