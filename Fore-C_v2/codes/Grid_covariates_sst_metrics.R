# Pull SST covariates to grid --------------------------------------------------

# load libraries
library(rcurl)
library(ncdf4)
library(tidyverse)

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
# load SST metrics (downloaded above)
wc <- nc_open(paste0(crw_dir, "WC.nc"))

hs <- nc_open(paste0(crw_dir, "HS.nc"))

sst90d <- nc_open(paste0(crw_dir, "SST90dMean.nc"))

# winter condition -------------------------------------------------------------
# this is a single value for each reef pixel
wc_id <- wc$dim$reef_id$vals
wc_vals <- ncvar_get(wc, varid = "daily_winter_conditions")

# fill in NAs with mean values
wc_vals[is.na(wc_vals)] <- mean(wc_vals, na.rm = T)

wc <- data.frame("ID" = wc_id,
                 "Winter_condition" = wc_vals)

save(wc, file = "../compiled_data/grid_covariate_data/grid_with_wc.RData")

# SST forecasts ----------------------------------------------------------------
# this code is not streamlined, lots of repeated code between hot snaps and 90 day means
# list dates/index associated with nowcasts and forecasts
nowcast_days <- seq(from = 1, to = 8, by = 7) # the first two weeks
forecast_days <- seq(from = 15, to = 15+(11*7), by = 7) # the following 12 weeks

# Hot Snaps --------------------------------------------------------------------
hs_df <- data.frame()

hs_id <- hs$dim$reef_id$vals

# dimensions: reef pixel ids x ensemble X days
hs_vals <- ncvar_get(hs, varid = "daily_hotsnap_prediction")

# This isn't working currently, check with Gang how day id is formatted
# # get day id
# day - based on last day of 7-day initial condition period (Oct 31-6), 239 total
# first day = Nov. 8, 2021
# julianday <- hs$dim$time$vals[1]
# # turn into julian day (first 3 numbers)
# julianday <- as.numeric(substr(julianday, 1, 3))
# # turn into date
# firstday <- as.Date(julianday, origin=as.Date("2021-01-01"))
firstday <- as.Date("2021-11-07", "%Y-%m-%d") # start date is 11/8, but using
# index to calculate from here, this will all need to be updated and should
# pull date directly from file

# nowcasts; currently using forecasts, will update in future with satellite observations
# subset to nowcast days
hs_nowcast <- hs_vals[,,nowcast_days]

# use median value across all forecasts
hs_nowcast <- apply(hs_nowcast, c(1,3), median, na.rm = T)

for(i in 1:length(nowcast_days)){
  x <- hs_nowcast[, i]
  x[is.na(x)] <- mean(x, na.rm = T)
  tmp_df <- data.frame("ID" = hs_id,
                       "Date" = firstday + i,
                       "Hot_snaps" = x,
                       "ensemble" = 0,
                       "type" = "nowcast")
  hs_df <- rbind(hs_df,
                 tmp_df)
}

# forecasts
for(j in 1:length(forecast_days)){
  # for each ensemble
  for(k in 1:28){
    x <- hs_vals[, k, forecast_days[j]]
    x[is.na(x)] <- mean(x, na.rm = T)
    tmp_df <- data.frame("ID" = hs_id,
                         "Date" = firstday + forecast_days[j],
                         "Hot_snaps" = x,
                         "ensemble" = k,
                         "type" = "forecast")
    hs_df <- rbind(hs_df,
                   tmp_df)
  }
}


# 90-day SST mean --------------------------------------------------------------
sst90d_df <- data.frame()

sst90d_id <- sst90d$dim$reef_id$vals

# dimensions: reef pixel ids x ensemble X days
sst90d_vals <- ncvar_get(sst90d, varid = "daily_90day_mean_sst_prediction")

# reuse first day from above, will update later

# nowcasts; currently using forecasts, will update in future with satellite observations
# subset to nowcast days
sst90d_nowcast <- sst90d_vals[,,nowcast_days]

# use median value across all forecasts
sst90d_nowcast <- apply(sst90d_nowcast, c(1,3), median, na.rm = T)

for(i in 1:length(nowcast_days)){
  x <- sst90d_nowcast[, i]
  x[is.na(x)|x > 40] <- mean(x, na.rm = T)
  tmp_df <- data.frame("ID" = sst90d_id,
                       "Date" = firstday + i,
                       "SST_90dMean" = x,
                       "ensemble" = 0,
                       "type" = "nowcast")
  sst90d_df <- rbind(sst90d_df,
                     tmp_df)
}


# forecasts
for(j in 1:length(forecast_days)){
  # for each ensemble
  for(k in 1:28){
    x <- sst90d_vals[, k, forecast_days[j]]
    x[is.na(x)|x > 40] <- mean(x, na.rm = T)
    tmp_df <- data.frame("ID" = sst90d_id,
                         "Date" = firstday + forecast_days[j],
                         "SST_90dMean" = x,
                         "ensemble" = k,
                         "type" = "forecast")
    sst90d_df <- rbind(sst90d_df,
                   tmp_df)
  }
}


# combine and save sst metrics -------------------------------------------------
reef_grid_sst <- hs_df %>%
  left_join(sst90d_df, 
            by = c("ID", "Date", "ensemble", "type"))


save(reef_grid_sst, file = "../compiled_data/grid_covariate_data/grid_with_sst_metrics.RData")
