library(rgdal)
library(raster)
library(data.table)
library(dplyr)

iDir <- "D:/Junk/eth_clipped/wgs84"

varLS <- c("cattle_density", "goat_density", "sheep_density", "drySsnYear_1981_2019_mean", 
           "ETH_Chloris_gayana_csuit", "ETH_Chloris_gayana_fsuit", "ETH_Lablab_purpureus_csuit", "ETH_Lablab_purpureus_fsuit",
           "lgp", "tt2lgpless150days")

aoi <- readOGR(paste0("E:/Data/Country/Ethiopia/Administrative/ETH_adm3.shp"))

varStats <- lapply(X = varLS, FUN = function(var) {
  
  ras <- raster(paste0(iDir, "/", var, ".tif"))
  

  # rasStats <- lapply(X = rasLS, FUN = function(ras) {
  #   
  #   ras <- raster(ras)
    
    crs(ras) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
    
    nPol <- length(aoi@polygons)
    
    shpStats <- lapply(1:nPol, function(p) {
      
      cat("Extracting : ", var, "Polygon", p, "\n")
      
      shpStats <- list()
      cname <- aoi@data$NAME_3[p]
      dname <- aoi@data$NAME_2[p]
      pol <- aoi@polygons[p]
      sh <- SpatialPolygons(pol)
      proj4string(sh) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
      
      # calculate stats
      vmin <- extract(ras, sh, fun = min, na.rm=TRUE)
      vmax <- extract(ras, sh, fun = max, na.rm = TRUE)
      vmean <- extract(ras, sh, fun = mean, na.rm = TRUE)
      vsum <- extract(ras, sh, fun = sum, na.rm =TRUE)
      
      area_polygon <- as.numeric(area(sh)/1000000)
      
      v2 <- as.data.frame(c(area_polygon, vmin, vmax, vmean, vsum))  #convert to dataframe
      v2 <- as.data.frame(t(v2))
      
      ras_names <- as.data.frame(names(ras))
      
      # combine layer names and data extract
      v2 <- cbind(ras_names, v2)
      
      # rename the columns
      colnames(v2) <- c("LAYER_NAME", "POLYGON_AREA", "MIN", "MAX", "MEAN", "SUM")
      
      row.names(v2) <- NULL
      
      d <- cbind(ZONE = rep(dname, times = nrow(v2)), 
                 WOREDA = rep(cname, times = nrow(v2)), 
                 VARIABLE = rep(var, times = nrow(v2)), v2)  #add data
      
      return(d)
      
    })
    test <- do.call("rbind", shpStats)
    
    return(shpStats)
    
  # })
  # 
  # rasStats <- do.call(rbind, rasStats)
  # return(rasStats)
  
})

varStats <- do.call(rbind, varStats)

write.csv(test, file = paste0(iDir, "/ethiopia_lgp_extract.csv"), row.names = FALSE)
