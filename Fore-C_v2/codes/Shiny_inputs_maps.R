# Create weekly maps for Shiny app ---------------------------------------------

# load libraries
library(leaflet)

# source scale bar function
source("./codes/custom_functions/fun_add_scalebar_to_map.R")

# source data
source("./codes/Shiny_inputs_update_polygons.R")


# create maps ------------------------------------------------------------------
bins <- seq(from = 0,
            to = 4, 
            by = 1
            )

cols <- c("#CCFFFF", 
          "#FFEF00",
          "#FFB300",
          "#EB1F08",
          "#8D1002"
          )

pal <- colorBin(cols, 
                domain = nowcast_polygons_5km$drisk, 
                bins = bins, 
                na.color = "transparent"
                )

legendLabels <- c("No stress", 
                  "Watch", 
                  "Warning", 
                  "Alert Level 1", 
                  "Alert Level 2"
                  )

# base map ---------------------------------------------------------------------
reefs_basemap <- leaflet() %>%
  addTiles(group = "OpenStreetMap") %>%
  addTiles(urlTemplate="http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}", group = "Satellite") %>%
  addScaleBar("topright") %>%
  leaflet::addLegend("topleft",
                     colors = cols,
                     labels = legendLabels,
                     title = "Disease risk",
                     opacity = 1)

# Map of nowcasts and near-term forecasts --------------------------------------
leaf_reefs <- reefs_basemap %>%
  addPolygons(data = nowcast_polygons_5km,
              layerId = ~ID,
              fillColor = ~pal(nowcast_polygons_5km$drisk),
              weight = 2,
              opacity = 1,
              color = ~pal(nowcast_polygons_5km$drisk),
              fillOpacity = 0.7,
              group = "Nowcast",
              highlightOptions = highlightOptions(color = "black", weight = 3, bringToFront = TRUE)
  ) %>%
  addPolygons(data = one_month_forecast_polygons_5km,
              layerId = ~ID,
              fillColor = ~pal(one_month_forecast_polygons_5km$drisk),
              weight = 2,
              opacity = 1,
              color = ~pal(one_month_forecast_polygons_5km$drisk),
              fillOpacity = 0.7,
              group = "One month forecast",
              highlightOptions = highlightOptions(color = "black", weight = 3, bringToFront = TRUE)
  ) %>%
  addPolygons(data = two_month_forecast_polygons_5km,
              layerId = ~ID,
              fillColor = ~pal(two_month_forecast_polygons_5km$drisk),
              weight = 2,
              opacity = 1,
              color = ~pal(two_month_forecast_polygons_5km$drisk),
              fillOpacity = 0.7,
              group = "Two month forecast",
              highlightOptions = highlightOptions(color = "black", weight = 3, bringToFront = TRUE)
  ) %>%
  addPolygons(data = polygons_GBRMPA_zoning,
              group = "GBRMPA nowcast",
              layerId = ~ID,
              color = ~pal(polygons_GBRMPA_zoning$drisk),
              highlightOptions = highlightOptions(color = "black", weight = 2, bringToFront = TRUE)
  ) %>%
  addPolygons(data = three_month_forecast_polygons_5km,
              layerId = ~ID,
              fillColor = ~pal(three_month_forecast_polygons_5km$drisk),
              weight = 2,
              opacity = 1,
              color = ~pal(three_month_forecast_polygons_5km$drisk),
              fillOpacity = 0.7,
              group = "Three month forecast",
              highlightOptions = highlightOptions(color = "black", weight = 3, bringToFront = TRUE)
  ) %>%
  addPolygons(data = polygons_management_zoning,
              group = "Management area nowcast",
              layerId = ~ID,
              color = ~pal(polygons_management_zoning$drisk),
              highlightOptions = highlightOptions(color = "black", weight = 2, bringToFront = TRUE)
  ) %>%
  addLayersControl(
    overlayGroups = c("Nowcast",
                      "One month forecast", 
                      "Two month forecast", 
                      "Three month forecast", 
                      "Management area nowcast", 
                      "GBRMPA nowcast"),
    baseGroups = c("Satellite", 
                   "OpenStreetMap"),
    options = layersControlOptions(collapsed = FALSE), # icon versus buttons with text
    position = c("bottomright")) %>%
  hideGroup(c("One month forecast", 
              "Two month forecast", 
              "Three month forecast", 
              "Management area nowcast", 
              "GBRMPA nowcast"))

save(leaf_reefs, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/leaf_reefs.Rds")

# Scenarios maps ---------------------------------------------------------------
scenarios_placeholder_map <- reefs_basemap %>%
  setView(lng = -150, lat = 0, zoom = 3)

save(scenarios_placeholder_map, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/scenarios_placeholder_map.Rds")

# ga gbr
scenarios_ga_gbr_map <- reefs_basemap %>% 
  addPolygons(data = ga_gbr_nowcast_polygons_5km,
              layerId = ~ID,
              fillColor = ~pal(ga_gbr_nowcast_polygons_5km$drisk),
              weight = 2,
              opacity = 1,
              color = ~pal(ga_gbr_nowcast_polygons_5km$drisk),
              fillOpacity = 0.7,
              group = "GA GBR nowcast",
              highlightOptions = highlightOptions(color = "black", weight = 3, bringToFront = TRUE)
  ) %>%
  addPolygons(data = ga_gbr_polygons_GBRMPA_zoning,
              group = "GA GBRMPA nowcast",
              layerId = ~ID,
              color = ~pal(ga_gbr_polygons_GBRMPA_zoning$drisk),
              highlightOptions = highlightOptions(color = "black", weight = 2, bringToFront = TRUE)
  ) %>%
  addPolygons(data = ga_gbr_polygons_management_zoning,
              group = "GA GBR management area nowcast",
              layerId = ~ID,
              color = ~pal(ga_gbr_polygons_management_zoning$drisk),
              highlightOptions = highlightOptions(color = "black", weight = 2, bringToFront = TRUE)
  ) %>%
  addLayersControl(
    overlayGroups = c("GA GBR nowcast",
                      "GA GBR management area nowcast", 
                      "GA GBRMPA nowcast"),
    baseGroups = c("Satellite", 
                   "OpenStreetMap"),
    options = layersControlOptions(collapsed = FALSE), # icon versus buttons with text
    position = c("bottomright")) %>%
  hideGroup(c("GA GBR management area nowcast", 
              "GA GBRMPA nowcast"))

save(scenarios_ga_gbr_map, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/scenarios_ga_gbr_map.Rds")

# ws gbr
scenarios_ws_gbr_map <- reefs_basemap %>% 
  addPolygons(data = ws_gbr_nowcast_polygons_5km,
              layerId = ~ID,
              fillColor = ~pal(ws_gbr_nowcast_polygons_5km$drisk),
              weight = 2,
              opacity = 1,
              color = ~pal(ws_gbr_nowcast_polygons_5km$drisk),
              fillOpacity = 0.7,
              group = "WS GBR nowcast",
              highlightOptions = highlightOptions(color = "black", weight = 3, bringToFront = TRUE)
  ) %>%
  addPolygons(data = ws_gbr_polygons_GBRMPA_zoning,
              group = "WS GBRMPA nowcast",
              layerId = ~ID,
              color = ~pal(ws_gbr_polygons_GBRMPA_zoning$drisk),
              highlightOptions = highlightOptions(color = "black", weight = 2, bringToFront = TRUE)
  ) %>%
  addPolygons(data = ws_gbr_polygons_management_zoning,
              group = "WS GBR management area nowcast",
              layerId = ~ID,
              color = ~pal(ws_gbr_polygons_management_zoning$drisk),
              highlightOptions = highlightOptions(color = "black", weight = 2, bringToFront = TRUE)
  ) %>%
  addLayersControl(
    overlayGroups = c("WS GBR nowcast",
                      "WS GBR management area nowcast", 
                      "WS GBRMPA nowcast"),
    baseGroups = c("Satellite", 
                   "OpenStreetMap"),
    options = layersControlOptions(collapsed = FALSE), # icon versus buttons with text
    position = c("bottomright")) %>%
  hideGroup(c("WS GBR management area nowcast", 
              "WS GBRMPA nowcast"))

save(scenarios_ws_gbr_map, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/scenarios_ws_gbr_map.Rds")

# ga pac
scenarios_ga_pac_map <- reefs_basemap %>% 
  addPolygons(data = ga_pac_nowcast_polygons_5km,
              layerId = ~ID,
              fillColor = ~pal(ga_pac_nowcast_polygons_5km$drisk),
              weight = 2,
              opacity = 1,
              color = ~pal(ga_pac_nowcast_polygons_5km$drisk),
              fillOpacity = 0.7,
              group = "GA Pacific nowcast",
              highlightOptions = highlightOptions(color = "black", weight = 3, bringToFront = TRUE)
  ) %>%
  addPolygons(data = ga_pac_polygons_management_zoning,
              group = "GA Pacific management area nowcast",
              layerId = ~ID,
              color = ~pal(ga_pac_polygons_management_zoning$drisk),
              highlightOptions = highlightOptions(color = "black", weight = 2, bringToFront = TRUE)
  ) %>%
  addLayersControl(
    overlayGroups = c("GA Pacific nowcast",
                      "GA Pacific management area nowcast"),
    baseGroups = c("Satellite", 
                   "OpenStreetMap"),
    options = layersControlOptions(collapsed = FALSE), # icon versus buttons with text
    position = c("bottomright")) %>%
  hideGroup("GA Pacific management area nowcast")

save(scenarios_ga_pac_map, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/scenarios_ga_pac_map.Rds")

# ws pac
scenarios_ws_pac_map <- reefs_basemap %>% 
  addPolygons(data = ws_pac_nowcast_polygons_5km,
              layerId = ~ID,
              fillColor = ~pal(ws_pac_nowcast_polygons_5km$drisk),
              weight = 2,
              opacity = 1,
              color = ~pal(ws_pac_nowcast_polygons_5km$drisk),
              fillOpacity = 0.7,
              group = "WS Pacific nowcast",
              highlightOptions = highlightOptions(color = "black", weight = 3, bringToFront = TRUE)
  ) %>%
  addPolygons(data = ws_pac_polygons_management_zoning,
              group = "WS Pacific management area nowcast",
              layerId = ~ID,
              color = ~pal(ws_pac_polygons_management_zoning$drisk),
              highlightOptions = highlightOptions(color = "black", weight = 2, bringToFront = TRUE)
  ) %>%
  addLayersControl(
    overlayGroups = c("WS Pacific nowcast",
                      "WS Pacific management area nowcast"),
    baseGroups = c("Satellite", 
                   "OpenStreetMap"),
    options = layersControlOptions(collapsed = FALSE), # icon versus buttons with text
    position = c("bottomright")) %>%
  hideGroup("WS Pacific management area nowcast")

save(scenarios_ws_pac_map, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/scenarios_ws_pac_map.Rds")
