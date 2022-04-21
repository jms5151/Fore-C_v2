library(tidyverse)

agg_to_manage_zones_forecasts <- function(forecast, zone_polygon_with_id, diseaseRegion, fileName){
  x <- merge(
    forecast
    , zone_polygon_with_id
    , by.x = "ID"
    , by.y = "PixelID"
    )
  
  x_agg <- x %>%
    group_by(
      PolygonID
      , Region
      , Date
      , type
      ) %>%
    summarise(
      Lwr = quantile(Lwr, 0.90)
      , value = quantile(value, 0.90)
      , Upr = quantile(Upr, 0.90)
      )
  
  if(diseaseRegion == "ga_gbr"){
    nostress_threshold <- 5
    watch_threshold <- 10
    warning_threshold <- 15
    alert1_threshold <- 25
  } else if(diseaseRegion == "ga_pac"){
    nostress_threshold <- 5
    watch_threshold <- 10
    warning_threshold <- 15
    alert1_threshold <- 25
  } else if(diseaseRegion == "ws_gbr"){
    nostress_threshold <- 1
    watch_threshold <- 5
    warning_threshold <- 10
    alert1_threshold <- 20
  } else if(diseaseRegion == "ws_pac"){
    nostress_threshold <- 1
    watch_threshold <- 5
    warning_threshold <- 10
    alert1_threshold <- 15
  } 
  
  x_agg$drisk <- NA
  x_agg$drisk[x_agg$value >= 0 & x_agg$value <= nostress_threshold] <- 0
  x_agg$drisk[x_agg$value > nostress_threshold & x_agg$value <= watch_threshold] <- 1
  x_agg$drisk[x_agg$value > watch_threshold & x_agg$value <= warning_threshold] <- 2
  x_agg$drisk[x_agg$value > warning_threshold & x_agg$value <= alert1_threshold] <- 3
  x_agg$drisk[x_agg$value > alert1_threshold] <- 4
  
  as.data.frame(x_agg)
}

agg_to_manage_zones_scenarios <- function(predictions, zone_polygon_with_id, fileName){
  aggregated_forecast <- merge(predictions,
                               zone_polygon_with_id,
                               by.x = "ID",
                               by.y = "PixelID")
  
  aggregated_forecast_to_management_zone <- aggregated_forecast %>%
    group_by(PolygonID, Region, Response, Response_level) %>%
    summarise_at(vars(value, estimate, LwrEstimate, UprEstimate, disease_risk_change), median) %>%
    mutate(ID = PolygonID) 
  
  aggregated_forecast_to_management_zone$PolygonID <- NULL
  
  as.data.frame(aggregated_forecast_to_management_zone)
  
}
