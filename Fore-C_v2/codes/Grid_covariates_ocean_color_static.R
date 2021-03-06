# Pull ocean color  co-variates to grid -----------------------------

# load libraries
library(ncdf4)
library(raster)
library(tidyverse)

# source custom function
source("./codes/custom_functions/fun_extract_oc_data_from_netcdf.R")

# load data ----------------------------------------------------------
# load ocean color data
oc_filepath <- "../raw_data/covariate_data/ocean_color/long_term_metrics_20220531.nc"
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
