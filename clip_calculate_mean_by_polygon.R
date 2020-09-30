# install.packages("raster") #into your R console 

library(raster)

#Note:
# (1) I assume that raster and vector are in one EPSG + vector is overlaping raster (polygons)
# (2) Vector and raster are in in project directory

#read shape file
shp = shapefile("Africa_boundaries_4326.shp")

# load reaster
img = raster("monthlyPCP1998_1.tif");

# filter by polygon ( this will go into loop)
country <- c("Algeria","Angola","Benin","Botswana","Burkina Faso","Burundi","Cameroon","Cape Verde","Central African Republic","Chad","Comoros","Congo","Djibouti","Egypt","Equatorial Guinea","Eritrea","Ethiopia","Gabon","Gambia, The","Gaza Strip","Ghana","Guinea","Guinea-Bissau","Ivory Coast","Kenya","Lebanon","Lesotho","Liberia","Libya","Madagascar","Malawi","Mali","Mauritania","Mauritius","Morocco","Mozambique","Namibia","Niger","Nigeria","Reunion","Rwanda","Sao Tome and Principe","Senegal","Seychelles","Sierra Leone","Somalia","South Africa","Sudan","Swaziland","Tanzania, United Republic of","Togo","Tunisia","Uganda","Western Sahara","Zaire","Zambia","Zimbabwe");

output <- matrix(ncol=3, nrow=length(country))

for (i in 1:length(country))
{
  
  # now filter
  filtered = shp[match(toupper(country[i]),toupper(shp$name)),]
  
  #now use the mask function
  # crop() has reduced the area for mask() thus very fast.
  rr <- mask(crop(img, filtered),filtered)
  
  country_sum <-cellStats(rr, mean, na.rm=TRUE);
  
  output[i,1] <- i;
  output[i,2] <- country[i];
  output[i,3] <- country_sum;
  
  #print(i,country_sum);
}

write.csv(output, file ="data.csv")

#ref
#http://gis.stackexchange.com/questions/61243/clipping-a-raster-in-r