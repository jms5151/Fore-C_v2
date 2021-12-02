# create polygons for management areas of reef grid pixels -------------------------

# load libraries
library(raster)
library(sf)
library(maptools)
library(gpclib)
library(rgeos)
library(rgdal)
library(dplyr)
library(sp)
library(leaflet)

# source custom functions
source("./codes/custom_functions/fun_create_polygon_from_shapefile.R")

# GBR -------------------------------------------------------------------------
# GBR layers from http://www.gbrmpa.gov.au/geoportal/catalog/download/download.page
# management areas
gbr_management_areas <- open_and_sp_transform_shp(shpFilepath = "../compiled_data/spatial_data/GBRMPA_shapefiles/Management_Areas_of_the_GBRMP__Poly_.shp",
                                                  crsInfo = "+init=epsg:4326"
                                                  )

gbr_management_areas <- format_sp_polygon(SPolygon = gbr_management_areas,
                                          idName = paste0("gbr_", gbr_management_areas@data$OBJECTID),
                                          typeName = gbr_management_areas@data$OBJECTID
                                          )

# zoning areas
gbr_park_zoning <- open_and_sp_transform_shp(shpFilepath = "../compiled_data/spatial_data/GBRMPA_shapefiles/Great_Barrier_Reef_Marine_Park_Zoning.shp",
                                                  crsInfo = "+init=epsg:4326"
                                             )

gbr_park_zoning <- format_sp_polygon(SPolygon = gbr_park_zoning,
                                          idName = paste0("gbr_", gbr_park_zoning@data$OBJECTID),
                                          typeName = gbr_park_zoning@data$TYPE
                                     )

polygons_GBRMPA_park_zoning <- spTransform(gbr_park_zoning, CRS("+init=epsg:4326")) %>%
  gBuffer(byid = TRUE, 
          width = 0
          ) # gbuffer used to overcome self-intersection error when determining 5km polygons ids within gbrmpa zone polygons

# check the zoning is correct
# leaflet() %>%
#   addTiles(group = "OpenStreetMap") %>%
#   addPolygons(data = polygons_GBRMPA_park_zoning)

# save data
save(polygons_GBRMPA_park_zoning,
     file = "../compiled_data/spatial_data/polygons_GBRMPA_park_zoning.Rds")

# GUAM ------------------------------------------------------------------------
# Guam MPA layer from https://www.oc.nps.edu/CMSP/Guam/
guam_mpas <- open_and_sp_transform_shp(shpFilepath = "../compiled_data/spatial_data/Guam_shapefiles/Guam_MPA_Boundaries.shp",
                                       crsInfo = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
                                       )

guam_mpas <- format_sp_polygon(SPolygon = guam_mpas,
                               idName = paste0("guam_", guam_mpas@data$Name),
                               typeName = guam_mpas@data$Name
                               )


# CNMI -----------------------------------------------------------------------
# CNMI MPA layer from https://www.oc.nps.edu/CMSP/CNMI/index.html
cnmi_mpas <- open_and_sp_transform_shp(shpFilepath = "../compiled_data/spatial_data/CNMI_shapefiles/CNMI_Marine_Protected_Areas.shp",
                                       crsInfo = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
                                       )

cnmi_mpas <- format_sp_polygon(SPolygon = cnmi_mpas,
                               idName = paste0("cnmi_", cnmi_mpas@data$OBJECTID),
                               typeName = cnmi_mpas@data$Regulation
                               )



# HAWAII ---------------------------------------------------------------------
# Hawaii layers from https://planning.hawaii.gov/gis/download-gis-data-expanded/ (use Marine Managed Areas (DAR))

hi_management_areas <- open_and_sp_transform_shp(shpFilepath = "../compiled_data/spatial_data/Hawaii_shapefiles/MMA_DAR.shp",
                                       crsInfo = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
                                       )

# change latitude to plot over antimeridian
for(i in  1:length(hi_management_areas@polygons)){
  for(j in 1:length(hi_management_areas@polygons[[i]]@Polygons)){ # polygons within polygons
    hi_management_areas@polygons[[i]]@Polygons[[j]]@coords[,1] <- hi_management_areas@polygons[[i]]@Polygons[[j]]@coords[,1] + 360
    hi_management_areas@polygons[[i]]@Polygons[[j]]@labpt[1] <- hi_management_areas@polygons[[i]]@Polygons[[j]]@labpt[1] + 360
  }
}

hi_management_areas <- format_sp_polygon(SPolygon = hi_management_areas,
                                         idName = paste0("hawaii_", hi_management_areas@data$Site_Name),
                                         typeName = hi_management_areas@data$MMA_design
                                         )


# Combine all regional management zone polygons ------------------------------- 
management_zone_polys_list <- list(gbr_management_areas,
                                   guam_mpas,
                                   cnmi_mpas,
                                   hi_management_areas) 

polygons_management_areas <- do.call(rbind, management_zone_polys_list)

# check polygons merged correctly by mapping
# leaflet() %>%
#   addTiles(group = "OpenStreetMap") %>%
#   addPolygons(data = polygons_management_areas)

# save data
save(polygons_management_areas, 
     file = "../compiled_data/spatial_data/polygons_management_areas.Rds")
