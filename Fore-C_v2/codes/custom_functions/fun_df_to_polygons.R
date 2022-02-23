library(tidyverse)
library(raster)

df_to_5km_polygon <- function(df){
  # create raster from point data
  x <- rasterFromXYZ(df[, c("Longitude"
                            , "Latitude" 
                            , "ID" 
                            )], 
                            crs = "+init=epsg:4326")
  
  rr <- rasterize(df[,c("Longitude", "Latitude")], 
                  x, 
                  field = df[,c("ID", "drisk")])
  
  # create spatial polygon from raster
  as(rr, "SpatialPolygonsDataFrame")
}


df_to_zone_polygons <- function(df, polygon_pixel_ids, zones_polygons, gbrOnly){
  
  # ga gbr
  ga_gbr <- df %>%
    filter(Disease == "GA" & Region == "gbr")
  
  ga_gbr_management <- agg_to_manage_zones_forecasts(
    forecast = ga_gbr
    , zone_polygon_with_id = polygon_pixel_ids
    , diseaseRegion = "ga_gbr")
  
  # ws gbr
  ws_gbr <- df %>%
    filter(Disease == "WS" & Region == "gbr")
  
  ws_gbr_management <- agg_to_manage_zones_forecasts(
    forecast = ws_gbr
    , zone_polygon_with_id = polygon_pixel_ids
    , diseaseRegion = "ws_gbr")
  
  # combine
  gbr <- bind_rows(
    ga_gbr_management
    , ws_gbr_management
    ) %>%
    group_by(PolygonID) %>%
    summarize("drisk" = max(drisk))
    
  if(gbrOnly == FALSE){
    # ga pac
    ga_pac <- df %>%
      filter(Disease == "GA" & Region != "gbr")
    
    ga_pac_management <- agg_to_manage_zones_forecasts(
      forecast = ga_pac
      , zone_polygon_with_id = polygon_pixel_ids
      , diseaseRegion = "ga_pac")
    
    # ws pac
    ws_pac <- df %>%
      filter(Disease == "WS" & Region != "gbr")
    
    ws_pac_management <- agg_to_manage_zones_forecasts(
      forecast = ws_pac
      , zone_polygon_with_id = polygon_pixel_ids
      , diseaseRegion = "ws_pac")
    
    # combine
    pac <- bind_rows(
      ga_pac_management
      , ws_pac_management
    ) %>%
      group_by(PolygonID) %>%
      summarize("drisk" = max(drisk))
    
    df_management_zones <- bind_rows(gbr, pac)
    
  } else if(gbrOnly == TRUE){
    
    df_management_zones <- gbr
    
  }
  
  merge(
    zones_polygons
    , df_management_zones
    , by.x = "ID"
    , by.y = "PolygonID"
    )
  
}

  
df_to_zone_polygons_region_specific <- function(df, data_date, region, diseaseRegionName, polygon_pixel_ids, zones_polygons){

  if(region == "gbr"){
    df2 <- df %>%
      filter(Date == data_date & Region == "gbr")
    new_polygon_pixel_ids <- polygon_pixel_ids[grep("gbr", polygon_pixel_ids$PolygonID),]
    new_zones_polygons <- zones_polygons[grep("gbr", zones_polygons$ID),]
  } else {
    df2 <- df %>%
      filter(Date == data_date & Region != "gbr")
    new_polygon_pixel_ids <- polygon_pixel_ids[!grepl("gbr", polygon_pixel_ids$PolygonID),]
    new_zones_polygons <- zones_polygons[!grepl("gbr", zones_polygons$ID),]
  }
  
  df_management_zones <- agg_to_manage_zones_forecasts(
    forecast = df2
    , zone_polygon_with_id = new_polygon_pixel_ids
    , diseaseRegion = diseaseRegionName
    )

  merge(
    new_zones_polygons
    , df_management_zones
    , by.x = "ID"
    , by.y = "PolygonID"
  )
  
}  
  