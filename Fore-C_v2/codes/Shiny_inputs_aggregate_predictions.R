# load libraries
library(tidyverse)

# load custom functions
source("./codes/custom_functions/fun_pixels_to_management_zones.R")

# load data
load("../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ga_forecast.RData")
load("../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ws_forecast.RData")

# load pixel information
load("../uh-noaa-shiny-app/forec_shiny_app_data/Static_data/pixels_in_management_areas_polygons.RData")
load("../uh-noaa-shiny-app/forec_shiny_app_data/Static_data/pixels_in_gbrmpa_park_zones_polygons.RData")

# set destination directory
forecast_file_dir <- "../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/"

# Nowcasts ---------------------------------------------------------------------
# subset data to most up to date nowcast
# ga_forecast <- ga_forecast[which(ga_forecast$Date == max(ga_forecast$Date[ga_forecast$type == "nowcast"])), ]
# ws_forecast <- ws_forecast[which(ws_forecast$Date == max(ws_forecast$Date[ws_forecast$type == "nowcast"])), ]

# aggregate to GBRMPA zones --------------------------------

# ga gbr gbrmpa zones -----
ga_gbr_nowcast_aggregated_to_gbrmpa_park_zones <- agg_to_manage_zones_forecasts(
        forecast = ga_forecast,
        zone_polygon_with_id = gbrmpa_park_zones_poly_pix_ids,
        diseaseRegion = "ga_gbr"
        )

save(ga_gbr_nowcast_aggregated_to_gbrmpa_park_zones,
     file = paste0(forecast_file_dir, 
                   "ga_gbr_nowcast_aggregated_to_gbrmpa_park_zones.RData"
                   )
     )

# ws gbr gbrmpa zones -----
ws_gbr_nowcast_aggregated_to_gbrmpa_park_zones <- agg_to_manage_zones_forecasts(
        forecast = ws_forecast,
        zone_polygon_with_id = gbrmpa_park_zones_poly_pix_ids,
        diseaseRegion = "ws_gbr"
        )

save(ws_gbr_nowcast_aggregated_to_gbrmpa_park_zones, 
     file = paste0(forecast_file_dir, 
                   "ws_gbr_nowcast_aggregated_to_gbrmpa_park_zones.RData"
                   )
     )

# Management zones ----------------------------------
# ga pacific management zones -----
ga_pac_nowcast_aggregated_to_management_zones <- agg_to_manage_zones_forecasts(
        forecast = ga_forecast,
        zone_polygon_with_id = management_area_poly_pix_ids,
        diseaseRegion = "ga_pac"
        )

save(ga_pac_nowcast_aggregated_to_management_zones, 
     file = paste0(forecast_file_dir, 
                   "ga_pac_nowcast_aggregated_to_management_zones.RData"
     )
)

# ga gbr management zones -----
ga_gbr_nowcast_aggregated_to_management_zones <- agg_to_manage_zones_forecasts(
        forecast = ga_forecast,
        zone_polygon_with_id = management_area_poly_pix_ids,
        diseaseRegion = "ga_gbr"
        )

save(ga_gbr_nowcast_aggregated_to_management_zones, 
     file = paste0(forecast_file_dir, 
                   "ga_gbr_nowcast_aggregated_to_management_zones.RData"
     )
)
# bind and save for growth anomalies:
ga_nowcast_aggregated_to_management_zones <- rbind(
        ga_pac_nowcast_aggregated_to_management_zones
        , ga_gbr_nowcast_aggregated_to_management_zones
        )

# save
save(ga_nowcast_aggregated_to_management_zones,
     file = paste0(forecast_file_dir, 
                   "ga_nowcast_aggregated_to_management_zones.RData"
                   )
     )

# ws pacific management zones ----
ws_pac_nowcast_aggregated_to_management_zones <- agg_to_manage_zones_forecasts(
        forecast = ws_forecast,
        zone_polygon_with_id = management_area_poly_pix_ids,
        diseaseRegion = "ws_pac"
)

save(ws_pac_nowcast_aggregated_to_management_zones,
     file = paste0(forecast_file_dir, 
                   "ws_pac_nowcast_aggregated_to_management_zones.RData"
     )
)

# ws gbr management zones -----
ws_gbr_nowcast_aggregated_to_management_zones <- agg_to_manage_zones_forecasts(
        forecast = ws_forecast,
        zone_polygon_with_id = management_area_poly_pix_ids,
        diseaseRegion = "ws_gbr"
        )

save(ws_gbr_nowcast_aggregated_to_management_zones,
     file = paste0(forecast_file_dir, 
                   "ws_gbr_nowcast_aggregated_to_management_zones.RData"
     )
)
# bind and save for white syndromes 
ws_nowcast_aggregated_to_management_zones <- rbind(
        ws_pac_nowcast_aggregated_to_management_zones
        , ws_gbr_nowcast_aggregated_to_management_zones
        )

# save
save(ws_nowcast_aggregated_to_management_zones,
     file = paste0(forecast_file_dir, 
                   "ws_nowcast_aggregated_to_management_zones.RData"
     )
)
