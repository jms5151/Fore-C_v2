set_regional_ids <- function(df, minLat, maxLat, minLon, maxLon, regionName, regionNumber){
  x <- subset(df, 
              Latitude > minLat & 
                Latitude < maxLat & 
                Longitude > minLon & 
                Longitude < maxLon
              )
  x$Region <- regionName
  startingId <- as.numeric(paste0(as.character(regionNumber), "0001"))
  x$ID <- seq(startingId, startingId+nrow(x)-1) 
  x
}