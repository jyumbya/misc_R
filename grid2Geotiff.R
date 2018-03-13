# convert multiple esri grid files into Geotiff

#libraries
library(raster)

# set variables
iDir <- "E:/Data/Country/Tanzania/GCMs"
oDir <- "E:/Data/Country/Tanzania/GCMs\tiffs"
rcpLs <- c("rcp26", "rcp45", "rcp60", "rcp85")
periodLs <- c("2020_2049", "2040_2069")
# varList <- c("prec", "tmax", "tmin", "tmean")

#loop periods and rcps
for (rcp in rcpLs){
  
  gcmList <- list.dirs(paste0(iDir, "/", rcp, "/Global_30s"), recursive = FALSE, full.names = FALSE)
  
  for (gcm in gcmList){
    
    for (period in periodLs){
      
      g_list <- list.files(paste0((iDir), "/", rcp, "/Global_30s/", gcm, "/r1i1p1/", period), pattern=".adf", full.names = TRUE)
      
      for (g in g_list){
        
        if(!file.exists(paste0(oDir, "/", rcp, "/Global_30s/", gcm, "/r1i1p1/", period, "/", sep="")))
        {dir.create(paste0(tDir, "/", rcp, "/Global_30s/", gcm, "/r1i1p1/", period, "/", sep=""), recursive=T)}
        
        writeRaster(g, filename = paste0(oDir, '/', w,".tiff"), format = "GTiff", overwrite=TRUE)
      }
    }
  }
}
