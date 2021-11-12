# list 5km polygons in each management area and gbrmpa park zone polygons -----

# load libraries
library(raster)

# source custom function
source("./codes/custom_functions/fun_list_polygon_intersection_ids.R")

# load polygons
load("../compiled_data/spatial_grid.Rds")
load("../../uh-noaa-shiny-app (jamie.sziklay@gmail.com)/forec_shiny_app_data/Static_data/polygons_management_areas.Rds")
load("../../uh-noaa-shiny-app (jamie.sziklay@gmail.com)/forec_shiny_app_data/Static_data/polygons_GBRMPA_park_zoning.Rds")

# pixels in regional management area polygons ---------------------------------
management_area_poly_pix_ids <- list_polygon_intersection_ids(polygonLargeArea = polygons_management_areas,
                                                              polygonSmallArea = polygons_5km
                                                              )

save(management_area_poly_pix_ids,
     file = "../../uh-noaa-shiny-app (jamie.sziklay@gmail.com)/forec_shiny_app_data/Static_data/pixels_in_management_areas_polygons.RData")

# pixels in gbrmpa park zones polygons ---------------------------------------
gbrmpa_park_zones_poly_pix_ids <- list_polygon_intersection_ids(polygonLargeArea = polygons_GBRMPA_park_zoning,
                                                                polygonSmallArea = polygons_5km
                                                                )

save(gbrmpa_park_zones_poly_pix_ids,
     file = "../../uh-noaa-shiny-app (jamie.sziklay@gmail.com)/forec_shiny_app_data/Static_data/pixels_in_gbrmpa_park_zones_polygons.RData")

