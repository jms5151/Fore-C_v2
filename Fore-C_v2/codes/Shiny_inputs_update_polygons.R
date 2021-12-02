# load libraries
library(tidyverse)
library(raster)

source("./codes/custom_functions/fun_pixels_to_management_zones.R")

# load data
load("../compiled_data/spatial_data/polygons_GBRMPA_park_zoning.Rds")
load("../compiled_data/spatial_data/polygons_management_areas.Rds")

load("../uh-noaa-shiny-app/forec_shiny_app_data/Static_data/pixels_in_management_areas_polygons.RData")
load("../uh-noaa-shiny-app/forec_shiny_app_data/Static_data/pixels_in_gbrmpa_park_zones_polygons.RData")

load("../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ga_forecast.RData")
load("../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ws_forecast.RData")

# set destination directory
forecast_file_dir <- "../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/"

# 5 km predictions to polygons -------------------------------------------------
# summarize forecasts 
reef_forecast <- bind_rows(ga_forecast, ws_forecast) %>%
  group_by(ID,
           Latitude,
           Longitude,
           Region) %>%
  summarize("risk" = max(value)) %>%
  mutate("drisk" = NA)

# format risk by stress status:
# 0 = No stress
# 1 = Watch
# 2 = Warning
# 3 = Alert Level 1
# 4 = Alert Level 2

reef_forecast$drisk[reef_forecast$risk == 0] <- 0
reef_forecast$drisk[reef_forecast$Region == "gbr" & reef_forecast$risk > 0 & reef_forecast$risk <= 1] <- 1
reef_forecast$drisk[reef_forecast$Region == "gbr" & reef_forecast$risk > 1 & reef_forecast$risk <= 5] <- 2
reef_forecast$drisk[reef_forecast$Region == "gbr" & reef_forecast$risk > 5 & reef_forecast$risk <= 10] <- 3
reef_forecast$drisk[reef_forecast$Region == "gbr" & reef_forecast$risk > 10] <- 4

reef_forecast$drisk[reef_forecast$Region != "gbr" & reef_forecast$risk > 0 & reef_forecast$risk <= 0.01] <- 1
reef_forecast$drisk[reef_forecast$Region != "gbr" & reef_forecast$risk > 0.01 & reef_forecast$risk <= 0.05] <- 2
reef_forecast$drisk[reef_forecast$Region != "gbr" & reef_forecast$risk > 0.05 & reef_forecast$risk <= 0.10] <- 3
reef_forecast$drisk[reef_forecast$Region != "gbr" & reef_forecast$risk > 0.10] <- 4

# to display over antimeridian in leaflap maps, add +360 to longitudes below zero
reef_forecast$Longitude <- ifelse(reef_forecast$Longitude < 0, reef_forecast$Longitude + 360, reef_forecast$Longitude) 

# create raster from point data
reefsDF2 <- rasterFromXYZ(reef_forecast[,c("Longitude", 
                                           "Latitude", 
                                           "ID")], 
                          crs = "+init=epsg:4326")

rr <- rasterize(reef_forecast[,c("Longitude", "Latitude")], 
                reefsDF2, 
                field = reef_forecast[,c("ID", "drisk")])

# create spatial polygon from raster
polygons_5km <- as(rr, "SpatialPolygonsDataFrame") # reefsDF2 go back to this when removing simulated prevalence

# save spatial polygon
save(polygons_5km, 
     file = paste0(forecast_file_dir, "polygons_5km.Rds"))


# 5 km predictions aggregated to management area polygons ----------------------
reef_forecast2 <- bind_rows(ga_forecast, ws_forecast)

reef_forecast_aggregated_to_management_zones <- agg_to_manage_zones(forecast = reef_forecast2,
                                                                    zone_polygon_with_id = management_area_poly_pix_ids)

reef_forecast_aggregated_to_management_zones <- reef_forecast_aggregated_to_management_zones %>%
  group_by(PolygonID) %>%
  summarize("drisk" = max(value))

polygons_management_zoning <- merge(polygons_management_areas,
                                    reef_forecast_aggregated_to_management_zones,
                                    by.x = "ID",
                                    by.y = "PolygonID"
                                    )


save(polygons_management_zoning,
     file = paste0(forecast_file_dir, "polygons_management_zoning.Rds"))


# 5 km predictions aggregated to gbrmpa zone polygons --------------------------
reef_forecast_aggregated_to_gbrmpa_park_zones <- agg_to_manage_zones(forecast = reef_forecast2,
                                                                     zone_polygon_with_id = gbrmpa_park_zones_poly_pix_ids)

reef_forecast_aggregated_to_gbrmpa_park_zones <- reef_forecast_aggregated_to_gbrmpa_park_zones %>%
  group_by(PolygonID) %>%
  summarize("drisk" = max(value))

polygons_GBRMPA_park_zoning <- merge(polygons_GBRMPA_park_zoning,
                                     reef_forecast_aggregated_to_gbrmpa_park_zones,
                                     by.x = "ID",
                                     by.y = "PolygonID"
                                     )


save(polygons_GBRMPA_park_zoning,
     file = paste0(forecast_file_dir, "polygons_GBRMPA_park_zoning.Rds"))
