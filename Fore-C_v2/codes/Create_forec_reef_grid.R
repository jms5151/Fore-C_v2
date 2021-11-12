# create grid for fore-c map ----------------------------------------------------
library(raster)

source("./codes/custom_functions/fun_set_regional_ids.R")

# Read in reef mask CSV. 0 = water, 1 = reef
# dims are 3600 rows (lats) 7200 cols (lons)
reefs <- read.csv("../raw_data/spatial_data/reef_plus_survey_gbr_deep_reef_remove_no_on_land_20211006.csv", header = FALSE)
regions_df <- read.csv("../raw_data/spatial_data/regional_boundary_coordinates.csv")

# Make 5km Grid
lon5km <- -179.975+0.05*seq(0,7199) # Columns
lat5km <- -89.975+0.05*seq(0,3599) # Rows

# Get reef pixel Lats and Lons
inds <- which(reefs == 1, arr.ind=TRUE)
reefLat <- lat5km[inds[,1]]
reefLon<- lon5km[inds[,2]]

reefsDF <- data.frame("Longitude" = reefLon, "Latitude" = reefLat)

# add region and ID
for(i in 1:nrow(regions_df)){
  x <- set_regional_ids(df = reefsDF, 
                        minLat = regions_df$lat1[i], 
                        maxLat = regions_df$lat2[i], 
                        minLon = regions_df$lon1[i], 
                        maxLon = regions_df$lon2[i], 
                        regionName = regions_df$region[i], 
                        regionNumber = regions_df$region_id[i]
                        )
  assign(regions_df$region[i], x)
  x <- NULL
}

# combine above datasets
reefsDF <- do.call(rbind, list(gbr, 
                               guam_cnmi, 
                               hawaii, 
                               johnston, 
                               prias, 
                               samoas, 
                               wake)
                   )

# save grid as csv
save(reefsDF, file = "../compiled_data/spatial_data/grid.RData")
