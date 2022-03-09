# load libraries
library(tidyverse)
library(raster)

source("./codes/custom_functions/fun_pixels_to_management_zones.R")
source("./codes/custom_functions/fun_df_to_polygons.R")

# load data
load("../compiled_data/spatial_data/polygons_GBRMPA_park_zoning.Rds")
load("../compiled_data/spatial_data/polygons_management_areas.Rds")

load("../uh-noaa-shiny-app/forec_shiny_app_data/Static_data/pixels_in_management_areas_polygons.RData")
load("../uh-noaa-shiny-app/forec_shiny_app_data/Static_data/pixels_in_gbrmpa_park_zones_polygons.RData")

load("../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ga_forecast.RData")
load("../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ws_forecast.RData")

# set destination directory
forecast_file_dir <- "../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/"

# format data -------------------------------------------------
# to display over antimeridian in leaflap maps, add +360 to longitudes below zero
ga_forecast$Longitude <- ifelse(ga_forecast$Longitude < 0, ga_forecast$Longitude + 360, ga_forecast$Longitude) 
ws_forecast$Longitude <- ifelse(ws_forecast$Longitude < 0, ws_forecast$Longitude + 360, ws_forecast$Longitude) 

# combine data
reef_forecast <- bind_rows(ga_forecast, ws_forecast)

# determine nowcast and forecast dates
prediction_dates <- unique(reef_forecast$Date)

nowcast_date <- reef_forecast$Date[which(reef_forecast$Date == max(reef_forecast$Date[reef_forecast$type == "nowcast"]))[1]]
nowcast_id <- which(prediction_dates == nowcast_date)

one_month_forecast_date <- prediction_dates[nowcast_id + 4]
two_month_forecast_date <- prediction_dates[nowcast_id + 8]
three_month_forecast_date <- prediction_dates[nowcast_id + 12]

# 5km nowcasts ------------------------------------------------ 
# summarize 
reef_nowcast <- reef_forecast %>%
  filter(Date == nowcast_date) %>%
  group_by(ID,
           Latitude,
           Longitude,
           Region) %>%
  summarize("drisk" = max(drisk)) 

# create polygons
nowcast_polygons_5km <- df_to_5km_polygon(df = reef_nowcast) 

# save 
save(nowcast_polygons_5km, 
     file = paste0(forecast_file_dir, "nowcast_polygons_5km.Rds"))

# 5km nowcasts, separate by disease and region for scenarios maps -----------
# ga gbr
ga_gbr_polygons_5km <- ga_forecast %>%
  filter(Date == nowcast_date & Region == "gbr")

ga_gbr_nowcast_polygons_5km <- df_to_5km_polygon(df = ga_gbr_polygons_5km) 

# save(ga_gbr_nowcast_polygons_5km, file = paste0(forecast_file_dir, "ga_gbr_nowcast_polygons_5km.Rds"))

# ga pac
ga_pac_polygons_5km <- ga_forecast %>%
  filter(Date == nowcast_date & Region != "gbr")

ga_pac_nowcast_polygons_5km <- df_to_5km_polygon(df = ga_pac_polygons_5km) 

# save(ga_pac_nowcast_polygons_5km, file = paste0(forecast_file_dir, "ga_pac_nowcast_polygons_5km.Rds"))

# ws gbr
ws_gbr_polygons_5km <- ws_forecast %>%
  filter(Date == nowcast_date & Region == "gbr")

ws_gbr_nowcast_polygons_5km <- df_to_5km_polygon(df = ws_gbr_polygons_5km) 

# save(ws_gbr_nowcast_polygons_5km, file = paste0(forecast_file_dir, "ws_gbr_nowcast_polygons_5km.Rds"))

# ws pac
ws_pac_polygons_5km <- ws_forecast %>%
  filter(Date == nowcast_date & Region != "gbr")

ws_pac_nowcast_polygons_5km <- df_to_5km_polygon(df = ws_pac_polygons_5km) 

# save(ws_pac_nowcast_polygons_5km, file = paste0(forecast_file_dir, "ws_pac_nowcast_polygons_5km.Rds"))

# 5km one month forecasts ------------------------------------- 
# summarize 
reef_forecast_one_month <- reef_forecast %>%
  filter(Date == one_month_forecast_date) %>%
  group_by(ID,
           Latitude,
           Longitude,
           Region) %>%
  summarize("drisk" = max(drisk)) 

# create polygons
one_month_forecast_polygons_5km <- df_to_5km_polygon(df = reef_forecast_one_month) 

# save 
# save(one_month_forecast_polygons_5km, 
#      file = paste0(forecast_file_dir, "one_month_forecast_polygons_5km.Rds"))

# 5km two month forecasts ------------------------------------- 
# summarize 
reef_forecast_two_month <- reef_forecast %>%
  filter(Date == two_month_forecast_date) %>%
  group_by(ID,
           Latitude,
           Longitude,
           Region) %>%
  summarize("drisk" = max(drisk)) 

# create polygons
two_month_forecast_polygons_5km <- df_to_5km_polygon(df = reef_forecast_two_month) 

# save 
# save(two_month_forecast_polygons_5km, 
#      file = paste0(forecast_file_dir, "two_month_forecast_polygons_5km.Rds"))

# 5km three month forecasts ------------------------------------- 
# summarize 
reef_forecast_three_month <- reef_forecast %>%
  filter(Date == three_month_forecast_date) %>%
  group_by(ID,
           Latitude,
           Longitude,
           Region) %>%
  summarize("drisk" = max(drisk)) 

# create polygons
three_month_forecast_polygons_5km <- df_to_5km_polygon(df = reef_forecast_three_month) 

# save 
# save(three_month_forecast_polygons_5km, 
#      file = paste0(forecast_file_dir, "three_month_forecast_polygons_5km.Rds"))

# Management area nowcast polygons ---------------------------------------------
# summarize data
ga_nowcast <- ga_forecast %>%
  filter(Date == nowcast_date) %>%
  mutate(Disease = "GA")

ws_nowcast <- ws_forecast %>%
  filter(Date == nowcast_date) %>%
  mutate(Disease = "WS")

nowcast_df <- bind_rows(ga_nowcast, ws_nowcast)

# Management areas -----------
polygons_management_zoning <- df_to_zone_polygons(
  df = nowcast_df
  , polygon_pixel_ids = management_area_poly_pix_ids
  , zones_polygons = polygons_management_areas
  , gbrOnly = FALSE
  )

# save(polygons_management_zoning,
#      file = paste0(forecast_file_dir, "polygons_management_zoning.Rds"))

# save by region
# ga gbr
ga_gbr_polygons_management_zoning <- df_to_zone_polygons_region_specific(
  df = ga_forecast
  , data_date = nowcast_date
  , region = "gbr"
  , diseaseRegionName = "ga_gbr"
  , polygon_pixel_ids = management_area_poly_pix_ids
  , zones_polygons = polygons_management_areas
)

# save(ga_gbr_polygons_management_zoning,
#      file = paste0(forecast_file_dir, "ga_gbr_polygons_management_zoning.Rds"))

# ga pac
ga_pac_polygons_management_zoning <- df_to_zone_polygons_region_specific(
  df = ga_forecast
  , data_date = nowcast_date
  , region = "pac"
  , diseaseRegionName = "ga_pac"
  , polygon_pixel_ids = management_area_poly_pix_ids
  , zones_polygons = polygons_management_areas
)

# save(ga_pac_polygons_management_zoning,
#      file = paste0(forecast_file_dir, "ga_pac_polygons_management_zoning.Rds"))

# ws gbr
ws_gbr_polygons_management_zoning <- df_to_zone_polygons_region_specific(
  df = ws_forecast
  , data_date = nowcast_date
  , region = "gbr"
  , diseaseRegionName = "ws_gbr"
  , polygon_pixel_ids = management_area_poly_pix_ids
  , zones_polygons = polygons_management_areas
)

# save(ws_gbr_polygons_management_zoning,
#      file = paste0(forecast_file_dir, "ws_gbr_polygons_management_zoning.Rds"))

# ws pac
ws_pac_polygons_management_zoning <- df_to_zone_polygons_region_specific(
  df = ws_forecast
  , data_date = nowcast_date
  , region = "pac"
  , diseaseRegionName = "ws_pac"
  , polygon_pixel_ids = management_area_poly_pix_ids
  , zones_polygons = polygons_management_areas
)

# save(ws_pac_polygons_management_zoning,
#      file = paste0(forecast_file_dir, "ws_pac_polygons_management_zoning.Rds"))

# GBRMPA zones -------
# subset data to only gbr
nowcast_df_gbr <- subset(nowcast_df, Region == "gbr")

polygons_GBRMPA_zoning <- df_to_zone_polygons(
  df = nowcast_df_gbr
  , polygon_pixel_ids = gbrmpa_park_zones_poly_pix_ids
  , zones_polygons = polygons_GBRMPA_park_zoning
  , gbrOnly = TRUE
  )

# save(polygons_GBRMPA_zoning,
#      file = paste0(forecast_file_dir, "polygons_GBRMPA_zoning.Rds"))

# save by disease
# ga
ga_gbr_polygons_GBRMPA_zoning <- df_to_zone_polygons_region_specific(
  df = ga_forecast
  , data_date = nowcast_date
  , region = "gbr"
  , diseaseRegionName = "ga_gbr"
  , polygon_pixel_ids = gbrmpa_park_zones_poly_pix_ids
  , zones_polygons = polygons_GBRMPA_park_zoning
)

# save(ga_gbr_polygons_GBRMPA_zoning,
#      file = paste0(forecast_file_dir, "ga_gbr_polygons_GBRMPA_zoning.Rds"))

# ws
ws_gbr_polygons_GBRMPA_zoning <- df_to_zone_polygons_region_specific(
  df = ws_forecast
  , data_date = nowcast_date
  , region = "gbr"
  , diseaseRegionName = "ws_gbr"
  , polygon_pixel_ids = gbrmpa_park_zones_poly_pix_ids
  , zones_polygons = polygons_GBRMPA_park_zoning
)

# save(ws_gbr_polygons_GBRMPA_zoning,
#      file = paste0(forecast_file_dir, "ws_gbr_polygons_GBRMPA_zoning.Rds"))


