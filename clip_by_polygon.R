library(raster)

iDir <- "E:/Data/Regional/Soil/Nutrients"

shp = shapefile("E:/Data/Regional/African_Countries/Africa_Countries.shp")

rastLs <- list.files(iDir, pattern = '.tif$', full.names = T)

country <- c("Kenya", "Uganda", "Zambia", "Ethiopia", "Rwanda", "Tanzania")

for (j in rastLs){
  
  img <- raster(j)
  
  for (i in 1:length(country)){
    
    filtered = shp[match(toupper(country[i]),toupper(shp$COUNTRY)),]
    
    name <- filtered$COUNTRY
    
    oDir <- paste0(iDir, "/output/", name, sep = "")
    
    if (!file.exists(oDir)) {
      dir.create(oDir, recursive = T)
    }
    
    img_clipped <- mask(crop(img, filtered), filtered)
    
    writeRaster(img_clipped, filename = paste0(oDir, "/", name, "_", names(img)), format = "GTiff", overwrite = TRUE)
    
    
    
  }
  

}