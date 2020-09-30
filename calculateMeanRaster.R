# calculate raster means

require(raster)
require(maptools)
require(rgdal)

iDir <- "E:/HS_West_Africa"
wa_countries <- readOGR("E:/HS_West_Africa/shapes/WA_country_main.shp") 
mask <- readOGR(paste0(iDir, "/shapes/mask.shp"))
thiLS <- c("none", "mild", "moderate", "severe")
modLS <- c("GFDL", "HADGEM2", "MPI")
periodLS <- c("2021_2050", "2071_2100")

# historical
thiStats <- lapply(thiLS, function(thi){

  freq <- raster(paste0(iDir, "/historical/outputs/frequency/p_", thi, "_avg.tif"))
  
  freq <- mask(crop(freq, extent(mask)), mask)
  
  d <- as.data.frame(cellStats(freq, mean, na.rm=TRUE))
  
  colnames(d) <- "MEAN_FREQUENCY"
  
  d <- cbind(THI_CLASS = rep(thi, times = nrow(d)), d)
  
  return(d)
  
})

thiStats <- do.call("rbind", thiStats)

write.csv(thiStats, file = paste0(iDir, "/historical_means.csv"), row.names = FALSE)

# historicalfuture
modStats <- lapply(modLS, function(mod){
  
  periodStats <- lapply(periodLS, function(period){
    
    thiStats <- lapply(thiLS, function(thi){
      
      thiStats <- list()
      
      freq <- raster(paste0(iDir, "/future/outputs/frequency/", mod, "/", period, "/p_", thi, "_avg.tif"))
      
      freq <- mask(crop(freq, extent(mask)), mask)
      
      d <- as.data.frame(cellStats(freq, mean, na.rm=TRUE))
      
      colnames(d) <- "MEAN_FREQUENCY"
      
      d <- cbind(THI_CLASS = rep(thi, times = nrow(d)), 
                 MODEL = rep(mod, times = nrow(d)), 
                 PERIOD = rep(period, times = nrow(d)), d)  #add data
      
      return(d)
      
    })
    
    thiStats <- do.call("rbind", thiStats)
    return(thiStats)
    
  })
  
  periodStats <- do.call(rbind, periodStats)
  return(periodStats)
  
  
})

modStats <- do.call(rbind, modStats)

write.csv(modStats, file = paste0(iDir, "/future_means.csv"), row.names = FALSE)




