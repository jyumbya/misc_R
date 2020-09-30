library(rgdal)
library(raster)
library(data.table)
library(dplyr)

iDir <- "D:/OneDrive - CGIAR/Data/Adaptation_atlas"

varLS <- c("aridity", "chirps_cv", "dry_days_hist_yearly", "heat_stress_flips", 
           "hi", "max_cons_dry_days_hist", "ppt_driest_month", "ppt_driest_quarter", 
           "thi")
aoi <- readOGR(paste0(iDir, "/ifad_tz_aoi.shp"))

varStats <- lapply(X = varLS, FUN = function(var) {
  
  # list files
  rasLs <- list.files(paste0(iDir, "/Tanzania/", var, "/"), pattern = ".tif$", 
                      full.names = TRUE)
  
  rasStats <- lapply(X = rasLs, FUN = function(ras) {
    
    ras <- raster(ras)
    
    crs(ras) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
    
    nPol <- length(aoi@polygons)
    
    shpStats <- lapply(1:nPol, function(p) {
      
      cat("Extracting : ", var, "Polygon", p, "\n")
      
      shpStats <- list()
      cname <- aoi@data$ADM1_EN[p]
      pol <- aoi@polygons[p]
      sh <- SpatialPolygons(pol)
      proj4string(sh) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
      
      # calculate mean
      v2 <- extract(ras, sh, fun = mean, na.rm = TRUE)
      
      v2 <- as.data.frame(v2)  #convert to dataframe
      v2 <- as.data.frame(t(v2))
      
      ras_names <- as.data.frame(names(ras))
      
      # combine layer names and data extract
      v2 <- cbind(ras_names, v2)
      
      # rename the columns
      colnames(v2) <- c("LAYER_NAME", "VALUE")
      
      row.names(v2) <- NULL
      
      d <- cbind(WARD = rep(cname, times = nrow(v2)), VARIABLE = rep(var, 
                                                                     times = nrow(v2)), v2)  #add data
      
      return(d)
      
    })
    shpStats <- do.call("rbind", shpStats)
    
    return(shpStats)
    
  })
  
  rasStats <- do.call(rbind, rasStats)
  return(rasStats)
  
})

varStats <- do.call(rbind, varStats)

write.csv(varStats, file = paste0(iDir, "/tanzania_extract.csv"), row.names = FALSE)
