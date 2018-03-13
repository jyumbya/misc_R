library(plotKML)
library(rgdal)


# set your working directory
setwd("D:/OneDrive - CGIAR/ToBackup/Projects/Land Degradation Neutrality_Namibia/Omusati/Sampling_sites")

# create output folder
if (!dir.exists('./outputs')) 
  dir.create('./outputs')

# read shapefile
polyg = readOGR(dsn=".", layer="Omusati_luc_sampling_sites")

# define shape of the points in the visualization
shape <- "http://maps.google.com/mapfiles/kml/pal2/icon18.png"

# export point data
kml(polyg, file.name = "./Omusati_luc_sampling_sites.kml", balloon = TRUE, shape = shape, colour_scale = SAGA_pal[[1]], points_names = polyg$Waypoint_N)

studyarea = readOGR(dsn="Data", layer="Omusati_adm2") # load study area

# set up leaflet
Omusati_ll<-leaflet() %>%
  addProviderTiles("Esri.WorldImagery") %>%
  
  # add data
  addMarkers(data = polyg, popup = ~as.character(Waypoint_N), 
             label = ~as.character(Waypoint_N), group = "Sampling sites") %>%
  addPolygons(data =studyarea, fill = FALSE, stroke = TRUE, 
              color = "#f93", group = "Study area") %>%
  
  # add a legend
  addLegend("bottomright", colors = c("#03F", "#f93"), 
            labels = c("Sampling sites", "Study area")) %>%
  
  # add layers control
  addLayersControl(
    overlayGroups = c("Sampling sites", "Study area"),
    options = layersControlOptions(collapsed = FALSE)
  )

# save as widget
saveWidget(Omusati_ll, file=paste0(getwd(),"/Omusati_luc_sampling_sites.html", sep=""))


