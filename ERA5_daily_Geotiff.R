# Produce daily GEOTIFFs from hourly ERA5 (one file per day) that have been downloaded locally
# bulk processing - this script could be converted to a function to run after each ERA5 netcdf file is downloaded
# Andy Nelson, 2019, a.nelson@utwente.nl

#install packages
if(!require("raster")) 
  install.packages("raster")

#load packages
library(raster)

# functions to convert ERA5 netcdf units to usual units for modelling. 
# Note that raster takes care of ERA5 offset and scale values.
# first set the NA value and make sure this is properly handled in each function.
myNA <- -32767

# temperatures to C from  Kelvin
K2C <- function(x)  { 
  ifelse(is.na(x) , myNA, (x - 273.15))
}

# rainfall to mm d-1 from from metres
m2mm <- function(x) { 
  ifelse(is.na(x) , myNA, (x * 1000.0))
}

# radiation to kJ m-2 d-1 from J m**-2 (accumulated from the beginning of the forecast, divide by 60*60*1000)
j2kj <- function(x) { 
  ifelse(is.na(x) , myNA, (x / 3600000.0))
}

# Mean actual (EA) and mean saturation vapour pressure (ES) in kPa
# Monteith JL (1973) Principles of environmental physics. Edward Arnold, London [4th Ed 2014]
# http://denning.atmos.colostate.edu/readings/Monteith.and.Unsworth.4thEd.pdf
# Also see http://www.fao.org/3/X0490E/x0490e07.htm
t2vp <- function(x)  { 
  ifelse(is.na(x) , myNA, (0.61078 * exp((17.2694 * (x - 273.15)) / ((x - 273.15) + 237.3))))
}

# Windspeed to m s-1 from two orthogonal components, u and v
spd <- function(x, y, ...)
{
  ifelse(is.na(x) | is.na(y), myNA, sqrt((x * x) + (y * y)))
}

# Relative humidity as % from EA (x) and ES (y), calculated from t2vp
rh <- function(x, y, ...)
{
  ifelse(is.na(x) | is.na(y), myNA, (100.0 * (x / y)))
}

# Set workding dir
mainDir <- "D:\\Data\\Personal\\Andy\\CDS\\ERA5"
setwd(mainDir)

# Some of these exist in ERA5, others are generated here such as the two vapour pressure vars, windspeed and relative humidity
varlist  <- c("2m_dewpoint_temperature","2m_temperature",
              "actual_vapour_pressure","saturation_vapour_pressure",
              "maximum_2m_temperature_since_previous_post_processing","minimum_2m_temperature_since_previous_post_processing",
              "surface_solar_radiation_downwards","total_precipitation",
              "relative_humidity","10m_wind")

# varlist  <- c("surface_solar_radiation_downwards","total_precipitation","10m_wind",
#               "maximum_2m_temperature_since_previous_post_processing","minimum_2m_temperature_since_previous_post_processing",
#               "2m_dewpoint_temperature","2m_temperature","actual_vapour_pressure","saturation_vapour_pressure","relative_humidity")


# for each variable
for (ERA5var in varlist)
{
  print(ERA5var)
  if(ERA5var=="2m_dewpoint_temperature"){name <- "2d"}   
  if(ERA5var=="2m_temperature"){name <- "2t"} 
  if(ERA5var=="maximum_2m_temperature_since_previous_post_processing"){name <- "mx2t"} 
  if(ERA5var=="minimum_2m_temperature_since_previous_post_processing"){name <- "mn2t"} 
  if(ERA5var=="surface_solar_radiation_downwards"){name <- "ssrd"} 
  if(ERA5var=="total_precipitation"){name <- "tp"} 
  if(ERA5var=="actual_vapour_pressure"){name <- "ea"} 
  if(ERA5var=="saturation_vapour_pressure"){name <- "es"} 
  if(ERA5var=="10m_wind"){name <- "wspd"} 
  if(ERA5var=="relative_humidity"){name <- "rh"} 
  
  #create directory if it does not exist
  if (file.exists(ERA5var)){
    setwd(file.path(mainDir, ERA5var))
  } else {
    dir.create(file.path(mainDir, ERA5var))
    setwd(file.path(mainDir, ERA5var))
  }
  for (ERA5yr in 2019:2019)
  {
    print(ERA5yr)
    # create directory if it does not exist 
    if (file.exists(dQuote(ERA5yr))){
      setwd(file.path(mainDir, ERA5var, ERA5yr))
    } else {
      dir.create(file.path(mainDir, ERA5var, ERA5yr))
      setwd(file.path(mainDir, ERA5var, ERA5yr))
    }
    
    # for each month and day
    for (ERA5mon in c("01","02","03","04","05","06","07","08","09","10","11","12"))
    {
      for (ERA5day in c("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"))
      {
        #outfile name
        outfile<-paste(name,"_",ERA5yr,"_",ERA5mon,"_",ERA5day,".tif",sep="")
        if (!file.exists(outfile)){
          ####################################################################################
          # check which variable we are processing, different procedure for each one. 
          if((ERA5var=="2m_dewpoint_temperature") || (ERA5var=="2m_temperature") || (ERA5var=="maximum_2m_temperature_since_previous_post_processing") || (ERA5var=="minimum_2m_temperature_since_previous_post_processing") || (ERA5var=="surface_solar_radiation_downwards") || (ERA5var=="total_precipitation")) {
            infile1<-paste(ERA5var,"_",ERA5yr,"_",ERA5mon,"_",ERA5day,".nc",sep="")
            if (file.exists(infile1)){
              #read in the 24 band netcdf file, one band per hour
              rt1 <- brick(infile1)
              NAvalue(rt1) <- myNA
              
              # generate a single band output by taking the mean, min, max or sum of hourly values, depending on variable
              # apply a conversion to the single day value based on the functions described above
              if((ERA5var=="2m_dewpoint_temperature") || (ERA5var=="2m_temperature")){
                ERA5data2<- stackApply(rt1, 1, fun = mean,na.rm=TRUE)
                NAvalue(ERA5data2) <- myNA
                ERA5data1 <- calc(ERA5data2,K2C)
              }
              if(ERA5var=="maximum_2m_temperature_since_previous_post_processing"){
                ERA5data2<- stackApply(rt1, 1, fun = max,na.rm=TRUE)
                NAvalue(ERA5data2) <- myNA
                ERA5data1 <- calc(ERA5data2,K2C)
              } 
              if(ERA5var=="minimum_2m_temperature_since_previous_post_processing"){
                ERA5data2<- stackApply(rt1, 1, fun = min,na.rm=TRUE)
                NAvalue(ERA5data2) <- myNA
                ERA5data1 <- calc(ERA5data2,K2C)
              } 
              if(ERA5var=="surface_solar_radiation_downwards"){
                ERA5data2 <- stackApply(rt1, 1, fun = sum,na.rm=TRUE)
                NAvalue(ERA5data2) <- myNA
                ERA5data1 <- calc(ERA5data2,j2kj)
              }
              if(ERA5var=="total_precipitation"){
                ERA5data2 <- stackApply(rt1, 1, fun = sum,na.rm=TRUE)
                NAvalue(ERA5data2) <- myNA
                ERA5data1 <- calc(ERA5data2,m2mm)
              }
            }
          }
          
          ####################################################################################
          if(ERA5var=="actual_vapour_pressure") {
            # dual file processing
            infile1<-paste(mainDir,"\\2m_dewpoint_temperature\\",ERA5yr,"\\2m_dewpoint_temperature","_",ERA5yr,"_",ERA5mon,"_",ERA5day,".nc",sep="")
            if (file.exists(infile1)){
              #read in the 24 band netcdf file, one band per hour
              rt1 <- brick(infile1)
              NAvalue(rt1) <- myNA
              
              # compute actual (ea) vapour pressure (in kPa) from dewpoint
              ERA5data2 <- calc(rt1,t2vp)
              NAvalue(ERA5data2) <- myNA
              ERA5data1<- stackApply(ERA5data2, 1, fun = mean,na.rm=TRUE)
            }
          }
          
          ####################################################################################
          if(ERA5var=="saturation_vapour_pressure") {
            # dual file processing
            infile1<-paste(mainDir,"\\2m_temperature\\",ERA5yr,"\\2m_temperature","_",ERA5yr,"_",ERA5mon,"_",ERA5day,".nc",sep="")
            if (file.exists(infile1)){
              #read in the 24 band netcdf file, one band per hour
              rt1 <- brick(infile1)
              NAvalue(rt1) <- myNA
              
              # compute saturation (es) vapour pressure (in kPa) from 2m temp
              ERA5data2 <- calc(rt1,t2vp)
              NAvalue(ERA5data2) <- myNA
              ERA5data1<- stackApply(ERA5data2, 1, fun = mean,na.rm=TRUE)
            }
          }
          
          ####################################################################################
          if(ERA5var=="10m_wind") {
            # dual file processing
            infile1<-paste(mainDir,"\\10m_u_component_of_wind\\",ERA5yr,"\\10m_u_component_of_wind","_",ERA5yr,"_",ERA5mon,"_",ERA5day,".nc",sep="")
            infile2<-paste(mainDir,"\\10m_v_component_of_wind\\",ERA5yr,"\\10m_v_component_of_wind","_",ERA5yr,"_",ERA5mon,"_",ERA5day,".nc",sep="")
            if (file.exists(infile1) && file.exists(infile2)){
              #read in both 24 band netcdf files, one band per hour for u and v wind components
              rt1 <- brick(infile1)
              rt2 <- brick(infile2)
              NAvalue(rt1) <- myNA
              NAvalue(rt2) <- myNA
              
              # windspeed needs needs two inputs,speeds in the u and v directions
              ERA5data2 <- overlay(rt1,rt2,fun=spd)
              NAvalue(ERA5data2) <- myNA
              ERA5data1 <- stackApply(ERA5data2,1,fun=mean,na.rm=TRUE)
            }
          }
          
          ####################################################################################
          if(ERA5var=="relative_humidity") {
            # dual file processing
            infile1<-paste(mainDir,"\\2m_dewpoint_temperature\\",ERA5yr,"\\2m_dewpoint_temperature","_",ERA5yr,"_",ERA5mon,"_",ERA5day,".nc",sep="")
            infile2<-paste(mainDir,"\\2m_temperature\\",ERA5yr,"\\2m_temperature","_",ERA5yr,"_",ERA5mon,"_",ERA5day,".nc",sep="")
            if (file.exists(infile1) && file.exists(infile2)){
              #read in the 24 band netcdf files, for dewpoint and mean temperature
              rt1 <- brick(infile1)
              rt2 <- brick(infile2)
              NAvalue(rt1) <- myNA
              NAvalue(rt2) <- myNA
              
              # relative humidity, needs two inputs,"2m_dewpoint_temperature","2m_temperature" RH = 100 * es(Td)/es(T)
              # compute actual (ea) vapour pressure (in kPa) from dewpoint
              ERA5data4 <- calc(rt1,t2vp)
              NAvalue(ERA5data4) <- myNA
              
              # compute sturation (es) vapour pressure (in kPa) from temperature
              ERA5data3 <- calc(rt2,t2vp)
              NAvalue(ERA5data3) <- myNA
              
              # compute rh per hour as 100 * ea / es
              ERA5data2 <- overlay(ERA5data4,ERA5data3,fun=rh)
              NAvalue(ERA5data2) <- myNA
              ERA5data1 <- stackApply(ERA5data2,1,fun=mean,na.rm=TRUE)
            }  
          }
          
          ####################################################################################
          # write out as GTiff file, but first rotate from 0 360 to usual -180 +180 
          if (file.exists(infile1)){
            ERA5data1_rot <- rotate(ERA5data1)
            # save as single band geotiff, one per day, using shortname (name) as defined above
            print(outfile)
            rf1 <- writeRaster(ERA5data1_rot, filename=outfile, format="GTiff", NAflag=myNA, overwrite=TRUE)
            # DOS command using gdal to set nodata and fix stats 
            # for /R G:\ %G in (*.tif) do gdal_edit -stats -a_nodata -32767 %G
            # for /R X:\CDS %G in (*.tif) do gdal_edit -stats -a_nodata -32767 %G
            # for /R X:\CDS\relative_humidity %G in (*.tif) do gdal_edit -stats -a_nodata -32767 %G
            # for /R D:\Data\Personal\Andy\CDS\Land\10m_wind\200* %G in (*.tif) do gdal_edit -stats -a_nodata -32767 %G
          }
        }
      }
    }
    setwd(file.path(mainDir, ERA5var))
  }
  setwd(mainDir)
} 

