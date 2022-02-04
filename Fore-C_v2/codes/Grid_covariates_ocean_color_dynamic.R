# Pull ocean color  co-variates to grid -----------------------------

# load libraries
library(ncdf4)
library(raster)
library(tidyverse)

# source custom function
source("./codes/custom_functions/fun_extract_oc_data_from_netcdf.R")

# list oc co-variates ----------------------------------------------
# source("./codes/Final_covariates_by_disease_and_region.R")
# 
# all_covars <- c(ga_gbr_vars
#                 , ga_pac_vars
#                 , ws_gbr_vars
#                 , ws_pac_acr_vars)
# 
# all_covars <- unique(all_covars)
# 
# oc_covars <- all_covars[grep('Kd', all_covars)]

# load data ----------------------------------------------------------
# load SST data to get matching dates 
load("../compiled_data/grid_covariate_data/grid_with_sst_metrics.RData")
oc_dates <- unique(reef_grid_sst$Date)

# load ocean color data
oc_filepath <- "../raw_data/covariate_data/ocean_color/long_term_metrics_20211121.nc"
oc <- nc_open(oc_filepath)

# load reef grid
load("../compiled_data/spatial_data/grid.RData")

# Make vector of latitudes and longitudes (same for all data) ------------------
lons <- oc$dim$lon$vals
lats <- oc$dim$lat$vals

# Extract seasonal ocean color data by pixel -----------------------------------

# turn list of dates in list of Julian days
julian_days <- as.numeric(strftime(oc_dates, 
                                   format = "%j")) # 14 weeks of predictions

# create empty data frames for data
TW_median <- data.frame()
TW_90th <- data.frame()

# loop through metrics and dates; this takes ~6 minutes
oc_metrics <- c("three_week_kd490_median", 
                "three_week_kd490_90th")

oc_metrics_names <- c("Three_Week_Kd_Median",
                      "Three_Week_Kd_90th")

for(i in 1:length(oc_metrics)){
  for(j in 1:length(julian_days)){
    x <- ncvar_get(oc, 
                   varid = oc_metrics[i], 
                   start = c(1, 1, julian_days[j]),
                   count = c(7200, 3600, 1))
    
    x2 <- extract_oc_data(variableMatrix = x,
                          reefgrid = reefsDF)
    
    tmp_df <- reefsDF
    tmp_df$Date <- oc_dates[j]
    tmp_df[, oc_metrics_names[i]] <- x2
    if(oc_metrics_names[i] == "Three_Week_Kd_Median"){
      TW_median <- rbind(TW_median, tmp_df)
    } else {
      TW_90th <- rbind(TW_90th, tmp_df)
    }
  }
}

tw_metrics <- TW_median %>%
  left_join(TW_90th, 
            by = c("Longitude", 
                   "Latitude", 
                   "Region", 
                   "ID", 
                   "Date"))

tw_metrics$Three_Week_Kd_Variability <- tw_metrics$Three_Week_Kd_90th - tw_metrics$Three_Week_Kd_Median

reef_grid_tw_oc <- tw_metrics[, c("Longitude",
                             "Latitude",
                             "Region",
                             "ID",
                             "Date",
                             "Three_Week_Kd_Median",
                             "Three_Week_Kd_Variability")]

save(reef_grid_tw_oc, file = "../compiled_data/grid_covariate_data/grid_with_three_week_oc_metrics.RData")

