# Access OSM data based
# https://dominicroye.github.io/en/2018/accessing-openstreetmap-data-with-r/
# load packages
library(tidyverse)
library(osmdata)
library(sf)
library(ggmap)

# the first five features
head(available_features())

aoi <- "Nairobi"

#set keys and values, reference: https://wiki.openstreetmap.org/wiki/Map_Features
osm_key <- "amenity"
osm_value <- "fast_food"


# building the query
q <- getbb(aoi) %>% opq() %>% add_osm_feature(osm_key, osm_value)

# make a sf object from the query
q <- osmdata_sf(q)


# background map
mad_map <- get_map(getbb(aoi), maptype = "hybrid")

# final map
ggmap(mad_map) + geom_sf(data = q$osm_points, inherit.aes = FALSE, colour = "#238443", 
                         fill = "#004529", alpha = 0.5, size = 4, shape = 21) + labs(x = "", 
                                                                                     y = "")

