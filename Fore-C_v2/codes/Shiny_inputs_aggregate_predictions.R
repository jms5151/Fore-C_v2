# load libraries
library(tidyverse)

# load custom functions
source("./codes/custom_functions/fun_pixels_to_management_zones.R")

# load data
load("../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ga_forecast.RData")
load("../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ws_forecast.RData")

# set destination directory
forecast_file_dir <- "../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/"

# aggregate to management zones --------------------------------

# ga gbr
ga_forecast_aggregated_to_gbrmpa_park_zones <- agg_to_manage_zones(forecast = ga_forecast,
                                                                   zone_polygon_with_id = gbrmpa_park_zones_poly_pix_ids)
save(ga_forecast_aggregated_to_gbrmpa_park_zones,
     file = paste0(forecast_file_dir, "ga_forecast_aggregated_to_gbrmpa_park_zones.RData"))


ga_forecast_aggregated_to_management_zones <- agg_to_manage_zones(forecast = ga_forecast,
                                                                  zone_polygon_with_id = management_area_poly_pix_ids)
save(ga_forecast_aggregated_to_management_zones,
     file = paste0(forecast_file_dir, "ga_forecast_aggregated_to_management_zones.RData"))


# ws gbr
ws_forecast_aggregated_to_gbrmpa_park_zones <- agg_to_manage_zones(forecast = ws_forecast,
                                                                   zone_polygon_with_id = gbrmpa_park_zones_poly_pix_ids)
save(ws_forecast_aggregated_to_gbrmpa_park_zones, 
     file = paste0(forecast_file_dir, "ws_forecast_aggregated_to_gbrmpa_park_zones.RData"))

ws_forecast_aggregated_to_management_zones <- agg_to_manage_zones(forecast = ws_forecast,
                                                                  zone_polygon_with_id = management_area_poly_pix_ids)
save(ws_forecast_aggregated_to_management_zones,
     file = paste0(forecast_file_dir, "ws_forecast_aggregated_to_management_zones.RData"))

# ga  pacific
ga_forecast_aggregated_to_management_zones <- agg_to_manage_zones(forecast = ga_forecast,
                                                                  zone_polygon_with_id = management_area_poly_pix_ids)
save(ga_forecast_aggregated_to_management_zones,
     file = paste0(forecast_file_dir, "ga_forecast_aggregated_to_management_zones.RData"))

# ws  pacific
ws_forecast_aggregated_to_management_zones <- agg_to_manage_zones(forecast = ws_forecast,
                                                                  zone_polygon_with_id = management_area_poly_pix_ids)
save(ws_forecast_aggregated_to_management_zones,
     file = paste0(forecast_file_dir, "ws_forecast_aggregated_to_management_zones.RData"))


