# extract nasa night time lights values for coral regions ---------------------- 

# load libraries
library(raster)
library(rgdal)

# load data
nightLights <- brick("../raw_data/covariate_data/BlackMarble_2016_3km_geo.tif")
load("../compiled_data/survey_data/Survey_points.RData")

# extract nighttime lights data for surveys
nightlights_s <- extract(nightLights, 
                         cbind(surveys$Longitude, 
                               surveys$Latitude
                               )
                         )

# merge data
reef_nightlights <- cbind(surveys, nightlights_s)

# save data
save(reef_nightlights, file = "compiled_data/survey_covariate_data/surveys_night_lights.RData")
