# Pull ocean color  covariates to grid -----------------------------------------

# load libraries
library(ncdf4)
library(raster)
library(tidyverse)

source("./codes/custom_functions/fun_extract_oc_data_from_netcdf.R")

# # not sure if it makes sense to try and automate names, given ------
# # nuances. Start of code to do that here, but may delete later
# # get names of ocean color covariates used in final models
# source("./codes/Final_covariates_by_disease_and_region.R")
# 
# covars <- c(ga_pac_vars,
#             ga_gbr_vars, 
#             ws_pac_acr_vars,
#             ws_gbr_vars)
# 
# covars <- unique(covars)
# 
# oc_covars <- covars[grep("Kd", covars)]

# load data --------------------------------------------------------------------
# load ocean color data
oc_filepath <- "../raw_data/covariate_data/ocean_color/long_term_metrics.nc"
oc <- nc_open(oc_filepath)

# load reef grid
load("../compiled_data/spatial_data/grid.RData")

# Make vector of latitudes and longitudes (same for all data) ------------------
lons <- oc$dim$lon$vals
lats <- oc$dim$lat$vals

# Extract long term ocean color data by pixel ----------------------------------
# create duplicate grid
reef_grid_lt_oc <- reefsDF

# Long term kd median
ltkdm <- ncvar_get(oc, varid = "long_term_kd490_median")
reef_grid_lt_oc$Long_Term_Kd_Median <- extract_oc_data(variableMatrix = ltkdm,
                                                       reefgrid = reef_grid_lt_oc)
# Long term kd 90th
ltkd90 <- ncvar_get(oc, varid = "long_term_kd490_90th")
Long_Term_Kd_90th <- extract_oc_data(variableMatrix = ltkd90,
                                     reefgrid = reef_grid_lt_oc)
# Long term kd variability
reef_grid_lt_oc$Long_Term_Kd_Variability <- Long_Term_Kd_90th - reef_grid_lt_oc$Long_Term_Kd_Median

save(reef_grid_lt_oc, file = "../compiled_data/grid_covariate_data/grid_with_long_term_oc_metrics.RData")

# Extract seasonal ocean color data by pixel -----------------------------------

# create list of Julian days for predictions, the first date should be automated!
first_date_of_data <- as.Date("2021-11-08")  

# create list of dates (important to do this first, if going over Dec-Jan)
dates_of_predictions <- seq.Date(from = first_date_of_data, 
                                 to = first_date_of_data + 13*7,
                                 by = "weeks")
  
# turn list of dates in list of Julian days
julian_days <- as.numeric(strftime(dates_of_predictions, 
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
    tmp_df$Date <- dates_of_predictions[j]
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
