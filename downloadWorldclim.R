library(raster)
outdir <- tempdir() # Specify your preferred working directory

# Downloading and unzipping
url <- "http://biogeo.ucdavis.edu/data/worldclim/v2.1/hist/wc2.1_2.5m_prec_2010-2018.zip"
zip <- file.path(outdir, basename(url))

# 3 GB download!
download.file(url, zip, mode = "wb")
f <- unzip(zip, list = TRUE)

# Only unzip 2017 and 2018
j <- grep("2017|2018", f$Name, value = TRUE)
ff <- unzip(zip, files = j, exdir = outdir)

# Yearly data
f1 <- grep("2017", ff, value = TRUE)
f2 <- grep("2018", ff, value = TRUE)
r1 <- stack(f1)
r2 <- stack(f2)

# Crop, mask, save by Burkina Faso boundary
v <- getData("GADM", country = "BFA", level = 0, path = outdir) 
r1 <- crop(r1, v)
r2 <- crop(r2, v)

# Each file has 12 bands (1:January ... 12:December)
r1 <- mask(r1, v, filename = file.path(outdir, "BFA_2017_prec.tif"))
r2 <- mask(r2, v, filename = file.path(outdir, "BFA_2018_prec.tif"))