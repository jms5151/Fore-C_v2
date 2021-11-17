# Pull SST covariates to grid --------------------------------------------------

# load libraries
# library(rcurl)
library(ncdf4)
library(raster)

# set crw forecast directory for downloads
crw_dir <- "../raw_data/covariate_data/CRW_dz_temp_metrics/crw_temp_forecasts/"

# Download SST metrics from CRW ------------------------------------------------
# there's a problem with the downloads, can't open as bricks, downloaded manually
# Winter Condition
wc_url = "ftp://ftp.star.nesdis.noaa.gov/pub/sod/mecb/gliu/caldwell/20211113/dz-v2_wdw_gbr_reef-id_20211107.nc"
download.file(wc_url, destfile = paste0(crw_dir, "WC.nc"))

# Hot Snaps
hs_url = "ftp://ftp.star.nesdis.noaa.gov/pub/sod/mecb/gliu/caldwell/20211111/cfsv2_hotsnap_gbr_reef-id_20211106.nc"
download.file(hs_url, destfile = paste0(crw_dir, "HS.nc"))

# 90 day mean SST
sst90dMean_url = "ftp://ftp.star.nesdis.noaa.gov/pub/sod/mecb/gliu/caldwell/20211114/cfsv2_mean-90d_gbr_reef-id_20211106_new.nc"
download.file(sst90dMean_url, destfile = paste0(crw_dir, "SST90dMean.nc"))

# load data --------------------------------------------------------------------
# load reef grid
load("../compiled_data/spatial_data/grid.RData")

# load SST metrics (downloaded above)
wc <- nc_open(paste0(crw_dir, "WC.nc"))
# wc <- raster(paste0(crw_dir, "WC.nc"), varname = "daily_winter_conditions")

hs <- nc_open(paste0(crw_dir, "HS.nc"))

sst <- brick(paste0(crw_dir, "SST90dMean.nc"))

# winter condition -------------------------------------------------------------
# this is a single value for each reef pixel
wc_vals <- ncvar_get(wc, varid = "daily_winter_conditions")
wc_id <- wc$dim$reef_id$vals

wc <- data.frame("ID" = wc_id,
                 "Winter_condition" = wc_vals)

save(wc, file = "../compiled_data/grid_covariate_data/grid_with_wc.RData")

# SST forecasts ----------------------------------------------------------------
# list dates/index associated with nowcasts and forecasts
nowcast_days <- seq(from = 1, to = 8, by = 7) # the first two weeks
forecast_days <- seq(from = 15, to = 15+(11*7), by = 7) # the following 12 weeks

# 90-day SST mean --------------------------------------------------------------
nowcast_days_indexes <- hs@data@names[nowcast_days]
forecast_days_indexes <- hs@data@names[forecast_days]

dayid <- hs$dim$time$vals
ensembleid <- hs$var$daily_hotsnap_prediction$dim[[2]]$vals
timeid <- hs$var$daily_hotsnap_prediction$dim[[3]]$vals
# values <- hs$var$daily_hotsnap_prediction$dim[[2]]$vals

str(x4)

x2 <- hs$X2459527$X2459527
plot(x2)


## rcurl to pull data
## 90 day means
## ftp://ftp.star.nesdis.noaa.gov/pub/sod/mecb/gliu/caldwell/20211111/cfsv2_mean-90d_gbr_reef-id_20211106.nc
## hot snaps
## ftp://ftp.star.nesdis.noaa.gov/pub/sod/mecb/gliu/caldwell/20211111/cfsv2_hotsnap_gbr_reef-id_20211106.nc
x <- brick("../raw_data/covariate_data/CRW_dz_temp_metrics/crw_temp_forecastscfsv2_hotsnap_gbr_reef-id_20211106.nc")

x2 <- x@data@names
unique(x2)

plot(x2)

x@file
str(x2)
head(reefsDF$ID)


t <- brick("../raw_data/covariate_data/CRW_dz_temp_metrics/cfsv2_hotsnap_gbr_reef-id_20211106.nc")


# ID number
t$X2459527@extent@xmax

#### this is where the values are stored ###
### Each "column" (X245...) = 1 day
### In each "column" there are 28 values for each pixel in GBR (total = 4808 pixels)
### Since it's unlikely we'll get nowcasts, we can use 16 weeks in future
### First day = Nov. 8, maybe start next week? Or maybe use Nov. 1 - 20 as "nowcast"?
### but that doesn't totally work with setup, unless we use average all all forecasts?
j <- t$X2459527
dim(j)
j[,1,]

unique(j)
unique(j@data@unit)

# day - based on last day of 7-day initial condition period (Oct 31-6), 239 total
# first day = Nov. 8, 2021
j@z
2459765 - 2459527
