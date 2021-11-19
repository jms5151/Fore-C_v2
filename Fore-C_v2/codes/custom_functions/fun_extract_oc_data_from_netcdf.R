# Extract ocean color data from netcdf file -------------------------------

library(ncdf4)
library(raster)

extract_oc_data <- function(variableMatrix, reefgrid){
  # Longitude need to be flipped for all variables
  x <- apply(variableMatrix, 1, rev)
  # create raster
  r <- raster(
    x,
    xmn = min(lons), 
    xmx = max(lons),
    ymn = min(lats), 
    ymx = max(lats),
    crs = CRS("+init=epsg:4326")
  )
  # extract data from raster to reef grid
  x <- extract(r, cbind(reefgrid$Longitude, reefgrid$Latitude))
  # replace NAs with median value - need to check this assumption with team
  x[is.na(x)] <- median(x, na.rm = T)
  # add extracted ocean color data to reef grid
  x
}
