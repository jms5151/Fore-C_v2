library(tidyverse)

agg_to_manage_zones <- function(forecast, zone_polygon_with_id, fileName){
  aggregated_forecast <- merge(forecast,
                               zone_polygon_with_id,
                               by.x = "ID",
                               by.y = "PixelID")
  
  aggregated_forecast_to_management_zone <- aggregated_forecast %>%
    group_by(PolygonID, Date, ensemble, type) %>%
    summarise_at(vars(value, Upr, Lwr), median)
  
  as.data.frame(aggregated_forecast_to_management_zone)
  
}