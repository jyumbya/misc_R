# convert a list of shapefiles to geojson format

library(sf)

iDir <- "D:/Junk"

shpLs <- list.files(paste0(iDir, "/"), pattern = ".shp$", full.names = TRUE)

for (shp in shpLs){
  
  shp_name <- gsub(".shp.*", "", gsub("D:/Junk/*", "", shp))
  
  shp <- st_read(shp)
  
  st_write(shp, paste0(iDir, "/", shp_name, ".geojson"), driver="GeoJSON", delete_dsn = TRUE)

}