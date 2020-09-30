require(raster)
require(rgdal)
library(maptools)

dirbase <- "F:/ClimateWizard/data/AR5_Global_Daily_25k/out_stats"
outdir <- "E:/cenavarro/csa_profiles"
mask1 <- readShapePoly("S:/admin_boundaries/adminFiles/10m-admin-0-countries.shp")

varList <- c("CDD", "HD18")
rcpList <- c("historical", "rcp45")
regList <- c("Ghana", "Ethiopia", "Uganda", "Niger", "Mali")

models <- list.dirs(dirbase, recursive = FALSE, full.names = FALSE)

## Cut by country

for (reg in regList){
  
  reg_shp <- mask1[mask1$COUNTRY == reg, ]
  
  #   reg_ext <- extent(reg_shp)
  #   
  #   ## Change longitude in 0-360 x axis
  #   xmin(reg_ext) <- xmin(reg_ext) + 180
  #   xmax(reg_ext) <- xmax(reg_ext) + 180
  #   
  for (model in models){    
    
    if (model != "GFDL-CM3" && model != "MIROC-ESM"){
      
      for (var in varList){
        
        for (rcp in rcpList){
          
          if (rcp == "historical"){
            period = "1950-2005"
          } else {
            period = "2006-2099"
            
          }
          
          cat(">. ", reg, rcp, period, model, var, "\n")
          rs_bn <- paste0(dirbase, "/", model, "/",var, "_BCSD_", rcp, "_", model, "_", period, ".nc4")
          
          if(file.exists(paste0(dirbase, "/", model, "/",var, "_BCSD_", rcp, "_", model, "_", period, ".nc4"))){
            
            ## Set outdir
            oDir <- paste0(outdir, "/", reg, "/by_model/downscaled/", rcp, "/", tolower(model))
            if (!file.exists(oDir)) {dir.create(oDir, recursive = T)}
            
            if (!file.exists(paste0(oDir, "/", var, "_ts.nc"))) {
              
              ## Load raster stack
              rs <- rotate(stack(rs_bn))
              
              ## Cut by mask raster stack 
              
              rs_crop <- crop(rs, extent(reg_shp))
              # rs_msk <- mask(rs_crop, reg_shp)
              
              ## Write timeseries
              rs_wr <- writeRaster(rs_crop, paste0(oDir, "/", tolower(var), "_ts.nc"), overwrite=T)
              
            }
            
          }

        }
        
        
        if(file.exists(paste0(outdir, "/", reg, "/by_model/downscaled/historical/", tolower(model), "/", tolower(var), "_ts.nc")) && file.exists(paste0(outdir, "/", reg, "/by_model/downscaled/rcp45/", tolower(model), "/", tolower(var), "_ts.nc"))){
          
          cat(" .. calculating anomalies \n")
          
          ## Select years (1960-1990)
          rs_hist <- stack(paste0(outdir, "/", reg, "/by_model/downscaled/historical/", tolower(model), "/", tolower(var), "_ts.nc"))[[12:41]]
          rs_hist_avg <- calc(rs_hist, mean)
          
          periods <- c(14, 34, 54)
          
          ## Calculate anomalies
          for (yif in periods){
            
            rs_fut <- stack(paste0(outdir, "/", reg, "/by_model/downscaled/rcp45/", tolower(model), "/", tolower(var), "_ts.nc"))[[yif:yif+29]]
            rs_fut_avg <- calc(rs_fut, mean)
            
            if (var == "CDD"){
              rs_anom <- (rs_fut_avg - rs_hist_avg) / rs_hist_avg * 100  
            } else {
              rs_anom <- rs_fut_avg - rs_hist_avg
            }
            
            ## Set outdir
            oAnomDir <- paste0(outdir, "/", reg, "/by_model/anomalies/rcp45/", tolower(model), "/", 2006 + yif, "_", 2006 + yif + 29)
            if (!file.exists(oAnomDir)) {dir.create(oAnomDir, recursive = T)}
            
            if (!file.exists(paste0(oAnomDir, "/", tolower(var), ".nc"))) {
              
              ## Write averages
              rs_anom <- writeRaster(rs_anom, paste0(oAnomDir, "/", tolower(var), ".nc"))
              
            }
          }
          
        }

      }
      
    }

  }
  
}
  
