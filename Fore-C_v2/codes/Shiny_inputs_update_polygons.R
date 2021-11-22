# update polygons_5km.RDS
library(raster)
library(tidyverse)

load("../../uh-noaa-shiny-app (jamie.sziklay@gmail.com)/forec_shiny_app_data/Forecasts/ga_forecast.RData")
load("../../uh-noaa-shiny-app (jamie.sziklay@gmail.com)/forec_shiny_app_data/Forecasts/ws_forecast.RData")

ga_nowcast <- ga_forecast %>%
  filter(Date == "2021-11-29") %>%
  mutate("ga" = Upr) %>%
  select(-c("Date", "Lwr", "value", "Upr"))

ws_nowcast <- ws_forecast %>%
  filter(Date == "2021-11-29") %>%
  mutate("ws" = Upr) %>%
  select(-c("Date", "Lwr", "value", "Upr"))

reef_forecast <- ga_nowcast %>%
  left_join(ws_nowcast) %>%
  mutate("drisk" = pmax(ga, ws))

# reef_forecast$drisk[reef_forecast$Region == "gbr"] <- reef_forecast$drisk[reef_forecast$Region == "gbr"]/5

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
save(polygons_5km, file = "../../uh-noaa-shiny-app (jamie.sziklay@gmail.com)/forec_shiny_app_data/Forecasts/polygons_5km.Rds")

# aggregate to maangement zones --------------------------------
load("../../uh-noaa-shiny-app (jamie.sziklay@gmail.com)/forec_shiny_app_data/Static_data/pixels_in_management_areas_polygons.RData")
load("../../uh-noaa-shiny-app (jamie.sziklay@gmail.com)/forec_shiny_app_data/Static_data/pixels_in_gbrmpa_park_zones_polygons.RData")

load("../../uh-noaa-shiny-app (jamie.sziklay@gmail.com)/forec_shiny_app_data/Forecasts/ga_forecast.RData")
load("../../uh-noaa-shiny-app (jamie.sziklay@gmail.com)/forec_shiny_app_data/Forecasts/ws_forecast.RData")

forecast_file_dir <- "../../uh-noaa-shiny-app (jamie.sziklay@gmail.com)/forec_shiny_app_data/Forecasts/"

agg_to_manage_zones <- function(forecast, zone_polygon_with_id, fileName){
  aggregated_forecast <- merge(forecast,
                               zone_polygon_with_id,
                               by.x = "ID",
                               by.y = "PixelID")
  
  aggregated_forecast_to_management_zone <- aggregated_forecast %>%
    group_by(PolygonID, Date, ensemble, type) %>%
    summarise_at(vars(value, Upr, Lwr), mean)
  
  as.data.frame(aggregated_forecast_to_management_zone)
  
}

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
# ga_forecast_aggregated_to_management_zones <- agg_to_manage_zones(forecast = ga_forecast,
#                                                                   zone_polygon_with_id = management_area_poly_pix_ids)
# save(ga_forecast_aggregated_to_management_zones, 
#      file = paste0(forecast_file_dir, "ga_forecast_aggregated_to_management_zones.RData"))
# 
# # ws  pacific
# ws_forecast_aggregated_to_management_zones <- agg_to_manage_zones(forecast = ws_forecast,
#                                                                   zone_polygon_with_id = management_area_poly_pix_ids)
# save(ws_forecast_aggregated_to_management_zones, 
#      file = paste0(forecast_file_dir, "ws_forecast_aggregated_to_management_zones.RData"))

# FUNCTION TO CREATE POLYGONS
# this doesn't work because management areas don't have lat/lon and 
# that's what's needed for this code
create_drisk_polygons <- function(reef_forecast){
  # create raster from point data
  reefsDF2 <- rasterFromXYZ(reef_forecast[,c("Longitude", 
                                             "Latitude", 
                                             "PolygonID")], 
                            crs = "+init=epsg:4326")
  
  rr <- rasterize(reef_forecast[,c("Longitude", "Latitude")], 
                  reefsDF2, 
                  field = reef_forecast[,c("PolygonID", "drisk")])
  
  # create spatial polygon from raster
  as(rr, "SpatialPolygonsDataFrame") # reefsDF2 go back to this when removing simulated prevalence
}

polygons_management_area <- create_drisk_polygons(reef_forecast = ga_forecast_aggregated_to_management_zones)

# save spatial polygon
save(polygons_5km, file = "../../uh-noaa-shiny-app (jamie.sziklay@gmail.com)/forec_shiny_app_data/Forecasts/polygons_5km.Rds")
