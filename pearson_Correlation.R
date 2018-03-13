library('raster', 'rgdal')  
setwd('C:\\Users\\jymutua\\Documents\\BDversus_30m')

list.files(pattern='tif')
layers <- list.files('.', pattern = '.tif$', full.names = TRUE)

r1=raster('otjo_bd1.tif')
r2=raster('otjo_bd2.tif')
r3=raster('otjo_bd3.tif')
r4=raster('ens_soc1.tif')
r5=raster('ens_soc2.tif')
r6=raster('ens_ocs.tif')

r.stack = stack(r1,r2,r3,r4,r5,r6)

jnk=layerStats(r.stack, 'pearson', na.rm=T)
corr_matrix=jnk$'pearson correlation coefficient'
corr_matrix

write.csv(corr_matrix, file = 'corr_matrix.csv')
