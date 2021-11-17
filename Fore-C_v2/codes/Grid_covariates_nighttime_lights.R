# load libraries
library(raster)
library(rgdal)

# load data
nightLights <- brick("../raw_data/covariate_data/BlackMarble_2016_3km_geo.tif")
load("../compiled_data/spatial_data/grid.RData")

# extract nighttime lights data for grid
nightlights_g <- extract(nightLights, cbind(reefsDF$Longitude, reefsDF$Latitude))

# merge data
reef_grid_nightlights <- cbind(reefsDF, nightlights_g)

# save data
save(reef_grid_nightlights, file = "../compiled_data/grid_covariate_data/grid_with_Night_Lights.RData")
