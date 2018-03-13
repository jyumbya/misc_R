### Author: John Mutua
### Calculate GCM ensembles and future climate means

require(raster)
require(maptools)
require(rgdal)

iDir  <- "E:/Data/Country/Tanzania/GCMs"
mask <- readOGR("D:/OneDrive - CGIAR/ToBackup/Projects/Livestock and Environment Flagship/Forage_suitability_modelling/data_current/aoi_tz.shp", layer= "aoi_tz") 
varList <- c("prec", "tmin", "tmax", "tmean") 
rcpList <- c("rcp26", "rcp45", "rcp60", "rcp85")
perList <- c("2020_2049", "2040_2069")

for (rcp in rcpList){

    gcmList <- list.dirs(paste0(iDir, "/", rcp, "/Global_30s"), recursive = FALSE, full.names = FALSE)
    gcmList <- gcmList [! gcmList %in% "ensemble"]

    cat("Ensemble over: ", rcp, "\n")

    for (period in perList) {

      oDirEns <- paste0("E:/Data/Country/Tanzania/GCMs/ensemble_30s/", rcp, "/", period)
      if (!file.exists(oDirEns)) {dir.create(oDirEns, recursive=T)}

      setwd(paste(iDir, "/", rcp, "/Global_30s", sep=""))

      if (!file.exists(paste(oDirEns, "/", var, "_12_sd.asc", sep=""))){

        for (var in varList){

          for (mth in 1:12){

            gcmStack <- stack(lapply(paste0(gcmList, "/r1i1p1/", period, "/", var, "_", mth, ".tiff"),FUN=raster))

            gcmMean <- mean(gcmStack)
            fun <- function(x) { sd(x) }
            gcmStd <- calc(gcmStack, fun)

            gcmMean <- trunc(gcmMean)
            gcmStd <- trunc(gcmStd)

            gcmMean <- writeRaster(gcmMean, paste(oDirEns, "/", var, "_", mth, ".tif", sep=""), overwrite=FALSE, format="GTiff", datatype='INT2S')
            gcmStd <- writeRaster(gcmStd, paste(oDirEns, "/", var, "_", mth, "_sd.tif", sep=""), overwrite=FALSE, format="GTiff", datatype='INT2S')
          }

        }
      }

    }



  cat("Seasonal Calcs ensemble over: ", rcp, "\n")
  varList <- c("prec", "tmin", "tmax", "tmean")

  # List of seasons
  seasons <- list("djf"=c(12,1,2), "mam"=3:5, "jja"=6:8, "son"=9:11, "ann"=1:12)

  for (period in perList) {

    oDirEns <- paste0("E:/Data/Country/Tanzania/GCMs/ensemble_30s/", rcp, "/", period)

    for (var in varList){

      # Load averages files
      iAvg <- stack(paste(oDirEns,'/', var, "_", 1:12, ".tif",sep=''))

      # Loop throught seasons
      for (i in 1:length(seasons)){


        if (!file.exists(paste(oDirEns,'/', var, "_", names(seasons[i]), '.tif',sep=''))){

          cat("Calcs ", var, names(seasons[i]), "\n")

          if (var == "prec"){

            sAvg = calc(iAvg[[c(seasons[i], recursive=T)]],fun=function(x){sum(x,na.rm=any(!is.na(x)))})

          } else {

            sAvg = calc(iAvg[[c(seasons[i], recursive=T)]],fun=function(x){mean(x,na.rm=T)})

          }

          writeRaster(sAvg, paste(oDirEns,'/', var, "_", names(seasons[i]), '.tif',sep=''),format="GTiff", overwrite=T, datatype='INT2S')

        }

      }

    }
  }
 
  ## Calculating future annual means
  for (period in perList) {
    
    oDirEns <- paste0("E:/Data/Country/Tanzania/GCMs/ensemble_30s/", rcp, "/", period)
    oDir <- paste0("D:/OneDrive - CGIAR/ToBackup/Projects/Livestock and Environment Flagship/Forage_suitability_modelling/data_future")
    
    # calculate annual precipitation
    p.stk <- stack(paste(oDirEns,'/prec_', 1:12, ".tif",sep=''))
    pSum <- sum(p.stk)
    writeRaster(pSum, paste0(oDir, "/", "annual_prec_", rcp, "_", period), format="GTiff", overwrite=T, datatype='INT2S')
    
    # calculate annual average temperature
    t.stk <- stack(paste(oDirEns,'/tmean_', 1:12, ".tif",sep=''))
    tAvg <- mean(t.stk, na.rm=TRUE)
    writeRaster(tAvg, paste0(oDir, "/annual_temp_", rcp, "_", period), format="GTiff", overwrite=T, datatype='INT2S')
  }
  
}
