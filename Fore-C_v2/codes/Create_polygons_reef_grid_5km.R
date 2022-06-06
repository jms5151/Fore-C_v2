# create 5km grid polygons -----------------------------------------

# load libraries
library(raster)
library(sp)
library(leaflet)

# load data
load("../compiled_data/spatial_data/grid.RData")

# to display over antimeridian in leaflap maps, add +360 to longitudes below zero
reefsDF$Longitude <- ifelse(reefsDF$Longitude < 0, reefsDF$Longitude + 360, reefsDF$Longitude) 

# create raster from point data
reefsDF2 <- rasterFromXYZ(reefsDF, crs = "+init=epsg:4326")

# # add sim prev data; remove if okay
# reefsDF$drisk <- rnorm(nrow(reefsDF), mean = 0.10, sd = 0.05)
# reefsDF$drisk[reefsDF$drisk < 0] <- 0
# rr <- rasterize(reefsDF[,c("Longitude", "Latitude")], reefsDF2, field = reefsDF[,c("ID", "drisk")])
rr <- rasterize(reefsDF[,c("Longitude", "Latitude")], reefsDF2, field = reefsDF[,c("ID")])

# create spatial polygon from raster
polygons_5km <- as(rr, "SpatialPolygonsDataFrame") 

# check map 
leaflet() %>%
  addTiles(group = "OpenStreetMap") %>%
  addPolygons(data = polygons_5km)

# save spatial polygon
save(polygons_5km, file = "../compiled_data/spatial_data/spatial_grid.Rds")

shapefile(polygons_5km, 
          filename = '../compiled_data/spatial_data/spatial_grid.shp')
