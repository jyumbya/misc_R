library(raster)
library(sp)
r <- raster(nrows=180, ncols=360, xmn=571823.6, xmx=616763.6, ymn=4423540, 
            ymx=4453690, resolution=270, crs = CRS("+proj=utm +zone=12 +datum=NAD83 
             +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"))
r[] <- rpois(ncell(r), lambda=1)
r <- calc(r, fun=function(x) { x[x >= 1] <- 1; return(x+1) } )
x <- sampleRandom(r, 10, na.rm = TRUE, sp = TRUE)
plot(r)
plot(x, add=TRUE, pch=20)


landcover.prop <- list()

for(i in 1:2) {
  landcover.prop[[i]] <- extract(r, x, buffer=500, small=TRUE, fun=function(x, p = i) 
  {prop.table(ifelse(x == p, 1, 0))})
}


landcover.prop <- do.call(rbind, landcover.prop)

test <- as.data.frame(landcover.prop)