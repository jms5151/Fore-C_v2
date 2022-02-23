# load libraries
library(tidyverse)

# load custom functions
source("./codes/custom_functions/fun_pixels_to_management_zones.R")

# load datam, set input/destination folder
scenarios_file_dir <- "../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/"

load(paste0(scenarios_file_dir, "ga_pac_scenarios.RData"))
load(paste0(scenarios_file_dir, "ws_pac_scenarios.RData"))
load(paste0(scenarios_file_dir, "ga_gbr_scenarios.RData"))
load(paste0(scenarios_file_dir, "ws_gbr_scenarios.RData"))

# load pixel information
load("../uh-noaa-shiny-app/forec_shiny_app_data/Static_data/pixels_in_management_areas_polygons.RData")
load("../uh-noaa-shiny-app/forec_shiny_app_data/Static_data/pixels_in_gbrmpa_park_zones_polygons.RData")

# aggregate to management zones --------------------------------

# ga gbr gbrmpa zones ------
ga_gbr_scenarios_aggregated_to_gbrmpa_park_zones <- agg_to_manage_zones_scenarios(
  predictions = ga_gbr_scenarios,
  zone_polygon_with_id = gbrmpa_park_zones_poly_pix_ids
  )

save(ga_gbr_scenarios_aggregated_to_gbrmpa_park_zones,
     file = paste0(
       scenarios_file_dir, 
       "ga_gbr_scenarios_aggregated_to_gbrmpa_park_zones.RData"
       )
     )

# ga gbr managment zones -----
ga_gbr_scenarios_aggregated_to_management_zones <- agg_to_manage_zones_scenarios(
  predictions = ga_gbr_scenarios,
  zone_polygon_with_id = management_area_poly_pix_ids
  )

save(ga_gbr_scenarios_aggregated_to_management_zones,
     file = paste0(
       scenarios_file_dir, 
       "ga_gbr_scenarios_aggregated_to_management_zones.RData"
       )
     )

# ws gbr gbrmpa zones -----
ws_gbr_scenarios_aggregated_to_gbrmpa_park_zones <- agg_to_manage_zones_scenarios(
  predictions = ws_gbr_scenarios,
  zone_polygon_with_id = gbrmpa_park_zones_poly_pix_ids
  )

save(ws_gbr_scenarios_aggregated_to_gbrmpa_park_zones, 
     file = paste0(scenarios_file_dir, 
                   "ws_gbr_scenarios_aggregated_to_gbrmpa_park_zones.RData"
                   )
     )

# ws gbr management zones -----
ws_gbr_scenarios_aggregated_to_management_zones <- agg_to_manage_zones_scenarios(
  predictions = ws_gbr_scenarios,
  zone_polygon_with_id = management_area_poly_pix_ids
  )

save(ws_gbr_scenarios_aggregated_to_management_zones,
     file = paste0(
       scenarios_file_dir, 
       "ws_gbr_scenarios_aggregated_to_management_zones.RData"
       )
     )

# ga pacific management zones -----
ga_pac_scenarios_aggregated_to_management_zones <- agg_to_manage_zones_scenarios(
  predictions = ga_pac_scenarios,
  zone_polygon_with_id = management_area_poly_pix_ids
  )

save(ga_pac_scenarios_aggregated_to_management_zones,
     file = paste0(scenarios_file_dir, 
                   "ga_pac_scenarios_aggregated_to_management_zones.RData"
                   )
     )

# ws pacific management zones -----
ws_pac_scenarios_aggregated_to_management_zones <- agg_to_manage_zones_scenarios(
  predictions = ws_pac_scenarios,
  zone_polygon_with_id = management_area_poly_pix_ids
  )

save(ws_pac_scenarios_aggregated_to_management_zones,
     file = paste0(
       scenarios_file_dir, 
       "ws_pac_scenarios_aggregated_to_management_zones.RData"
       )
     )
