# function to extract aggregated point values within each pixel

aggregate_point_values <- function(df, x, fn){
  # create raster of df data
  dat <- df[, c(x, "Longitude", "Latitude")]
  dat <- as.data.frame(dat)
  coordinates(dat) = ~Longitude+Latitude
  proj4string(dat) = CRS("+init=epsg:4326") # set it to lat-long
  reefs_raster = raster(dat)
  # calculate mean values across all df points within each grid pixel
  dat2 <- rasterize(dat, reefs_raster, x, fun = fn, na.rm = T)
  # extract data points for each pixel in grid
  extract(dat2, cbind(reefsDF$Longitude, reefsDF$Latitude))
}