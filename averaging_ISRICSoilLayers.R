## Average ISRIC soil layers (1:4) using trapezoidal rule based on Hengl et al., 2017
## Calculate categorical mode using ISRIC soil layers (1:4)
## John Mutua

# load libraries
library(raster)

# Set working dir

# list and stack layers accordingly
setwd("D:/Trash/soil_grids1km")
r.list <- list.files('.', pattern = '.tif$', full.names = F)
s <- stack(r.list[1:4])

# Implement trapezoidal rule
p <- (0.0333 * 0.5)*((5-0)*(s[[1]]+s[[2]])+(15-5)*(s[[2]]+s[[3]])+(30-15)*(s[[3]]+s[[4]]))

# Write output
writeRaster(p, filename = "soc.tif", format = "GTiff", overwrite = TRUE, datatype='INT2S')

##################################################################################
##################################################################################

### AFRICA250m
setwd("E:/TZ_Soil Organic")
r.list <- list.files('.', pattern = '.tif$', full.names = F)
s <- stack(r.list)

# average 0 to 30 com
p <- ((5*s[[1]]+10*s[[2]]+15*s[[3]])/30)
# p <- ((15*s[[1]]+45*s[[2]])/60) # aluminum concentration at 0-60

# Write output
writeRaster(p, filename = "soc_0_30.tif", format = "GTiff", overwrite = TRUE, datatype='INT2S')



### Calculate categorical mode ####

# load libraries
library(DescTools)
library(raster)

# Set working dir

# list and stack layers accordingly
setwd("D:/Trash/Soil texture")

#categorical mode function
categorical.mode <- function(pixel){
  mode.pixel <- DescTools::Mode(x = pixel)[1]
  return(mode.pixel)
}

# list, stack layers calculate mode accordingly
r.list <- list.files('.', pattern = '.tif$', full.names = F)
r.mode <- calc(stack(r.list[1:4]), fun=categorical.mode)

# write ouput
writeRaster(r.mode, filename = "soil_texture.tif", format = "GTiff", overwrite=TRUE)
