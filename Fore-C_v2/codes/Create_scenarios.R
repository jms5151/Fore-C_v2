# create list of scenarios
library(tidyverse)

# create temporary directory
scenarios_inputs_dir <- "../compiled_data/scenarios_inputs/"
if(dir.exists(scenarios_inputs_dir) == FALSE){
  dir.create(scenarios_inputs_dir)
}

# load data 
load("../compiled_data/forecast_inputs/grid_with_dynamic_predictors.RData")
load("../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ga_forecast.RData")
load("../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ws_forecast.RData")

# get current data date
current_nowcast_date <- max(grid_with_dynamic_predictors$Date[grid_with_dynamic_predictors$type == "nowcast"])

# subset data
nowcast_predictor_data <- subset(grid_with_dynamic_predictors, Date == current_nowcast_date)
ga_nowcast <- subset(ga_forecast, Date == current_nowcast_date)
ws_nowcast <- subset(ws_forecast, Date == current_nowcast_date)

# model covariates
source("./codes/Final_covariates_by_disease_and_region.R")

# custom function for creating scenarios 
source("./codes/custom_functions/fun_create_scenarios.R")

# load pixel information
load("../uh-noaa-shiny-app/forec_shiny_app_data/Static_data/pixels_in_management_areas_polygons.RData")
load("../uh-noaa-shiny-app/forec_shiny_app_data/Static_data/pixels_in_gbrmpa_park_zones_polygons.RData")

# GA Pacific -------------------------------------
ga_pac <- subset(ga_nowcast, Region != "gbr")

ga_pac <- ga_pac %>%
  left_join(nowcast_predictor_data)

colnames(ga_pac) <- gsub("Poritidae_|_Poritidae", "", colnames(ga_pac))

# Base values ---------------------
# Save base values for each pixel for covariates with sliders
ga_pac_basevals_ID <- ga_pac[, c('ID'
                                 , 'Median_colony_size'
                                 , 'mean_cover'
                                 , 'BlackMarble_2016_3km_geo.3'
                                 , 'value')]

# ga_pac_basevals_ID$value <- round(ga_pac_basevals_ID$value*100)
ga_pac_basevals_ID$value <- round(ga_pac_basevals_ID$value)
save(ga_pac_basevals_ID, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/ga_pac_basevals_ID.RData")

# Save base values for management zones
ga_pac_basevals_management <- merge(
  ga_pac_basevals_ID
  , management_area_poly_pix_ids
  , by.x = "ID"
  , by.y = "PixelID"
  ) 

ga_pac_basevals_management <- ga_pac_basevals_management %>%
  mutate(ID = NULL,
         ID = PolygonID,
         PolygonID = NULL) %>%
  group_by(ID) %>%
  summarise_all(mean) %>%
  as.data.frame()

save(ga_pac_basevals_management, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/ga_pac_basevals_management.RData")

# create scenarios ---------------------

ga_pac_scenarios <- data.frame()

# Colony size
ga_pac_coral_size_levels <- seq(from = 5, to = 65, by = 10) 

ga_pac_scenarios <- add_scenario_levels(
  df = ga_pac
  , scenario_levels = ga_pac_coral_size_levels
  , col_name = 'Median_colony_size'
  , response_name = 'Coral size'
  , scenarios_df = ga_pac_scenarios
)

# coral cover
ga_pac_coral_cover_levels <- seq(from = 5, to = 65, by = 10) 

ga_pac_scenarios <- add_scenario_levels(
  df = ga_pac
  , scenario_levels = ga_pac_coral_cover_levels
  , col_name = 'mean_cover'
  , response_name = 'Coral cover'
  , scenarios_df = ga_pac_scenarios
)

# coastal development
ga_pac_development_levels <- seq(from = 1, to = 255, length.out = 11)# 

ga_pac_scenarios <- add_scenario_levels(
  df = ga_pac
  , scenario_levels = ga_pac_development_levels
  , col_name = 'BlackMarble_2016_3km_geo.3'
  , response_name = 'Development'
  , scenarios_df = ga_pac_scenarios
)


save(ga_pac_scenarios
     , file = paste0(scenarios_inputs_dir, "ga_pac_scenarios.RData"))

# WS Pacific -------------------------------------
ws_pac <- subset(ws_nowcast, Region != "gbr")

ws_pac <- ws_pac %>%
  left_join(nowcast_predictor_data)

# not sure if we want to do this - problems with predicting scenarios
colnames(ws_pac) <- gsub("Acroporidae_|_Acroporidae", "", colnames(ws_pac))

# Base values ----------------------------
# Save base values for each pixel for covariates with sliders
ws_pac_basevals_ID <- ws_pac[, c('ID'
                                 , 'Median_colony_size'
                                 , 'Long_Term_Kd_Median'
                                 , 'mean_cover'
                                 , 'H_abund'
                                 , 'value')]

ws_pac_basevals_ID$value <- round(ws_pac_basevals_ID$value)
save(ws_pac_basevals_ID, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/ws_pac_basevals_ID.RData")

# Save base values for management zones
ws_pac_basevals_management <- merge(
  ws_pac_basevals_ID
  , management_area_poly_pix_ids
  , by.x = "ID"
  , by.y = "PixelID"
) 

ws_pac_basevals_management <- ws_pac_basevals_management %>%
  mutate(ID = NULL,
         ID = PolygonID,
         PolygonID = NULL) %>%
  group_by(ID) %>%
  summarise_all(mean) %>%
  as.data.frame()

save(ws_pac_basevals_management, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/ws_pac_basevals_management.RData")

# create scenarios ---------------------

ws_pac_scenarios <- data.frame()

# colony size
ws_pac_coral_size_levels <- seq(from = 5, to = 65, by = 10) 

ws_pac_scenarios <- add_scenario_levels(
  df = ws_pac
  , scenario_levels = ws_pac_coral_size_levels
  , col_name = 'Median_colony_size'
  , response_name = 'Coral size'
  , scenarios_df = ws_pac_scenarios
  )

# turbidity
ws_pac_turbidity_levels <- seq(from = 0, to = 2, by = 0.1) 

ws_pac_scenarios <- add_scenario_levels(
  df = ws_pac
  , scenario_levels = ws_pac_turbidity_levels
  , col_name = 'Long_Term_Kd_Median'
  , response_name = 'Turbidity'
  , scenarios_df = ws_pac_scenarios
)

# coral cover
ws_pac_coral_cover_levels <- seq(from = 5, to = 65, by = 10) 

ws_pac_scenarios <- add_scenario_levels(
  df = ws_pac
  , scenario_levels = ws_pac_coral_cover_levels
  , col_name = 'mean_cover'
  , response_name = 'Coral cover'
  , scenarios_df = ws_pac_scenarios
)

# herbivorous fish
ws_pac_herb_fish_levels <- seq(from = 0.0, to = 0.6, by = 0.1)

ws_pac_scenarios <- add_scenario_levels(
  df = ws_pac
  , scenario_levels = ws_pac_herb_fish_levels
  , col_name = 'H_abund'
  , response_name = 'Herb. fish'
  , scenarios_df = ws_pac_scenarios
)

save(ws_pac_scenarios
     , file = paste0(scenarios_inputs_dir, "ws_pac_scenarios.RData"))

# GA GBR -----------------------------------------
ga_gbr <- subset(ga_nowcast, Region == "gbr")

ga_gbr <- ga_gbr %>%
  left_join(nowcast_predictor_data[, c("ID", "Region", ga_gbr_vars)])

# Base values ---------------
# Save base values for each pixel for covariates with sliders
ga_gbr_basevals_ID <- ga_gbr[, c('ID'
                                 , 'Fish_abund'
                                 , 'Long_Term_Kd_Variability'
                                 , 'value')]

save(ga_gbr_basevals_ID, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/ga_gbr_basevals_ID.RData")

# Save base values for gbrmpa zones
ga_gbr_basevals_gbrmpa <- merge(
  ga_gbr_basevals_ID
  , gbrmpa_park_zones_poly_pix_ids
  , by.x = "ID"
  , by.y = "PixelID"
)

ga_gbr_basevals_gbrmpa <- ga_gbr_basevals_gbrmpa %>%
  mutate(ID = NULL,
         ID = PolygonID,
         PolygonID = NULL) %>%
  group_by(ID) %>%
  summarise_all(mean) %>%
  as.data.frame()

save(ga_gbr_basevals_gbrmpa, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/ga_gbr_basevals_gbrmpa.RData")

# Save base values for management zones
ga_gbr_basevals_management <- merge(
  ga_gbr_basevals_ID
  , management_area_poly_pix_ids
  , by.x = "ID"
  , by.y = "PixelID"
)

ga_gbr_basevals_management <- ga_gbr_basevals_management %>%
  mutate(ID = NULL,
         ID = PolygonID,
         PolygonID = NULL) %>%
  group_by(ID) %>%
  summarise_all(mean) %>%
  as.data.frame()

save(ga_gbr_basevals_management, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/ga_gbr_basevals_management.RData")

# create scenarios --------------------------------

ga_gbr_scenarios <- data.frame()

# Fish abundance
ga_gbr_fish_levels <- seq(from = 400, to = 800, by = 50)

ga_gbr_scenarios <- add_scenario_levels(
  df = ga_gbr
  , scenario_levels = ga_gbr_fish_levels
  , col_name = 'Fish_abund'
  , response_name = 'Fish'
  , scenarios_df = ga_gbr_scenarios
)

# turbidity
ga_gbr_turbidity_levels <- seq(from = 0, to = 2, by = 0.1) 

ga_gbr_scenarios <- add_scenario_levels(
  df = ga_gbr
  , scenario_levels = ga_gbr_turbidity_levels
  , col_name = 'Long_Term_Kd_Variability'
  , response_name = 'Turbidity'
  , scenarios_df = ga_gbr_scenarios
)

save(ga_gbr_scenarios
     , file = paste0(scenarios_inputs_dir, "ga_gbr_scenarios.RData"))

# WS GBR -----------------------------------------
ws_gbr <- subset(ws_nowcast, Region == "gbr")

ws_gbr_vars <- gsub("Coral_cover", "Coral_cover_plating", ws_gbr_vars)

ws_gbr <- ws_gbr %>%
  left_join(nowcast_predictor_data[, c("ID", "Region", ws_gbr_vars)]) %>%
  mutate("Coral_cover" = Coral_cover_plating)

# Base values -----------------------
# Save base values for each pixel for covariates with sliders
ws_gbr_basevals_ID <- ws_gbr[, c('ID'
                                 , 'Coral_cover'
                                 , 'Fish_abund'
                                 , 'Three_Week_Kd_Variability'
                                 , 'value')]

save(ws_gbr_basevals_ID, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/ws_gbr_basevals_ID.RData")

# Save base values for gbrmpa zones
ws_gbr_basevals_gbrmpa <- merge(
  ws_gbr_basevals_ID
  , gbrmpa_park_zones_poly_pix_ids
  , by.x = "ID"
  , by.y = "PixelID"
)

ws_gbr_basevals_gbrmpa <- ws_gbr_basevals_gbrmpa %>%
  mutate(ID = NULL,
         ID = PolygonID,
         PolygonID = NULL) %>%
  group_by(ID) %>%
  summarise_all(mean) %>%
  as.data.frame()

save(ws_gbr_basevals_gbrmpa, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/ws_gbr_basevals_gbrmpa.RData")

# Save base values for management zones
ws_gbr_basevals_management <- merge(
  ws_gbr_basevals_ID
  , management_area_poly_pix_ids
  , by.x = "ID"
  , by.y = "PixelID"
)

ws_gbr_basevals_management <- ws_gbr_basevals_management %>%
  mutate(ID = NULL,
         ID = PolygonID,
         PolygonID = NULL) %>%
  group_by(ID) %>%
  summarise_all(mean) %>%
  as.data.frame()


save(ws_gbr_basevals_management, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/ws_gbr_basevals_management.RData")

# create scenarios ------------------------

ws_gbr_scenarios <- data.frame()

# coral cover
ws_gbr_coral_cover_levels <- seq(from = 5, to = 95, by = 10) 

ws_gbr_scenarios <- add_scenario_levels(
  df = ws_gbr
  , scenario_levels = ws_gbr_coral_cover_levels
  , col_name = 'Coral_cover'
  , response_name = 'Coral cover'
  , scenarios_df = ws_gbr_scenarios
)

# Fish abundance
ws_gbr_fish_levels <- seq(from = 400, to = 800, by = 50)

ws_gbr_scenarios <- add_scenario_levels(
  df = ws_gbr
  , scenario_levels = ws_gbr_fish_levels
  , col_name = 'Fish_abund'
  , response_name = 'Fish'
  , scenarios_df = ws_gbr_scenarios
)

# turbidity
ws_gbr_turbidity_levels <- seq(from = 0, to = 2, by = 0.1) 

ws_gbr_scenarios <- add_scenario_levels(
  df = ws_gbr
  , scenario_levels = ws_gbr_turbidity_levels
  , col_name = 'Three_Week_Kd_Variability'
  , response_name = 'Turbidity'
  , scenarios_df = ws_gbr_scenarios
)

save(ws_gbr_scenarios
     , file = paste0(scenarios_inputs_dir, "ws_gbr_scenarios.RData"))

