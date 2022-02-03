library(tidyverse)

agg_to_manage_zones_forecasts <- function(forecast, zone_polygon_with_id, fileName){
  aggregated_forecast <- merge(forecast,
                               zone_polygon_with_id,
                               by.x = "ID",
                               by.y = "PixelID")
  
  aggregated_forecast_to_management_zone <- aggregated_forecast %>%
    group_by(PolygonID, Region, Date, ensemble, type) %>%
    summarise_at(vars(value, Upr, Lwr), median)
  
  as.data.frame(aggregated_forecast_to_management_zone)
  
}

agg_to_manage_zones_scenarios <- function(predictions, zone_polygon_with_id, fileName){
  aggregated_forecast <- merge(predictions,
                               zone_polygon_with_id,
                               by.x = "ID",
                               by.y = "PixelID")
  
  aggregated_forecast_to_management_zone <- aggregated_forecast %>%
    group_by(PolygonID, Region, Response, Response_level) %>%
    summarise_at(vars(value, estimate, sd, disease_risk_change), median) %>%
    mutate(ID = PolygonID) 
  
  aggregated_forecast_to_management_zone$PolygonID <- NULL
  
  as.data.frame(aggregated_forecast_to_management_zone)
  
}
