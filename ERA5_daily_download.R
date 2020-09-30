# Run with Rscript ERA5_daily_download  arg1 arg2 arg3
# Download ERA5 variables, one per day, as netcdf files
# Priors - requires a CDS account and installation of Anaconda and the
# Andy Nelson, 2019, a.nelson@utwente.nl
# Adam Sparks, 2019, Adam.Sparks@usq.edu.au

# install python Anaconda first https://www.anaconda.com/distribution/#download-section

#install packages
if (!require("lubridate"))
  install.packages("lubridate")
if (!require("reticulate"))
  install.packages("reticulate")
if (!require("tidyverse"))
  install.packages("tidyverse")
if (!require("purrr"))
  install.packages("purrr")

#load packages
library(tidyverse)
library(reticulate)
library(lubridate)
library(purrr)

mainDir <- "D:\\Data\\Personal\\Andy\\CDS\\ERA5"
setwd(mainDir)

# install the CDS API - only do this once, then comment out
# conda_install("r-reticulate","cdsapi",pip=TRUE)
# fix ENV variables too
# see https://medium.com/@adit.cm/error-on-anaconda-creating-new-environment-using-conda-command-on-windows-7-cb0758431654

# you must create a CDS account and then copy your .cdsapirc to C:\Users\nelsonad\Documents
# format is
# url: https://cds.climate.copernicus.eu/api/v2
# key: UID:API key

cdsapi <- import('cdsapi')
server = cdsapi$Client() #start the connection

varlist  <- c("2m_dewpoint_temperature","2m_temperature",
              "maximum_2m_temperature_since_previous_post_processing","minimum_2m_temperature_since_previous_post_processing",
              "surface_solar_radiation_downwards","total_precipitation",
              "10m_u_component_of_wind", "10m_v_component_of_wind")

#use lubridate to create a vector of dates from 1998 to present day
#dates <-
#  as.character(seq(ymd("1998-01-01"), ymd(Sys.Date()), by = "1 day"))

#use lubridate to create a vector of dates from 1998 to last processed day [usually 2-3 months behind current date]
dates <-
  as.character(seq(ymd("2019-09-01"), ymd("2019-11-30"), by = "1 day"))

for (ERA5var in varlist) {
  #create dir
  if (file.exists(ERA5var)) {
    setwd(file.path(mainDir, ERA5var))
  } else {
    dir.create(file.path(mainDir, ERA5var))
    setwd(file.path(mainDir, ERA5var))
  }
  
  for (ERA5date in dates) {
    #create dir if !exists
    if (file.exists(substr(ERA5date, 1, 4))) {
      setwd(file.path(mainDir, ERA5var, substr(ERA5date, 1, 4)))
    } else {
      dir.create(file.path(mainDir, ERA5var, substr(ERA5date, 1, 4)))
      setwd(file.path(mainDir, ERA5var, substr(ERA5date, 1, 4)))
    }
    
    #we create the query for one variable for a single day
    query <- r_to_py(
      list(
        variable = ERA5var,
        product_type = "reanalysis",
        year = str_pad(substr(ERA5date, 1, 4), 2, "left", "0"),
        month = str_pad(substr(ERA5date, 6, 7), 2, "left", "0"),
        day = str_pad(substr(ERA5date, 9, 10), 2, "left", "0"),
        time = str_c(0:23, "00", sep = ":") %>% str_pad(5, "left", "0"),
        format = "netcdf"
      )
    )
    infile <-
      paste0(
        ERA5var,
        "_",
        substr(ERA5date, 1, 4),
        "_",
        substr(ERA5date, 6, 7),
        "_",
        substr(ERA5date, 9, 10),
        ".nc"
      )
    if (!file.exists(infile)) {
      print(infile)
      # purrr is part of tidyverse, we'll use it to download files and
      # handle exceptions (e.g., a failed download)
      s_retrieve <- safely(server$retrieve)
      s_retrieve("reanalysis-era5-single-levels", query, infile)
    }
    
    setwd(file.path(mainDir, ERA5var))
  }
  
  setwd(mainDir)
}


# check for any files that were not downloaded
# create list of downloaded files
download_files <-
  list.files(mainDir, recursive = TRUE, full.names = TRUE)

# create list of files that WERE to be downloaded
file_check <- paste0(
  path.expand(mainDir),
  "/",
  varlist,
  "/",
  unique(substr(dates, 1, 4)),
  "/",
  apply(expand.grid(varlist, dates), 1, paste, collapse = "_"),
  ".nc"
)

# make file names match for checking
file_check <-
  gsub("-", "_", file_check) # replace "-" in dates with "_" to match filenames

# check for missing files in downloaded files
missing_files <- file_check[file_check %in% download_files == FALSE]
missing_files
