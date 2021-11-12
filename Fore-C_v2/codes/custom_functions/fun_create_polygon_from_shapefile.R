library(rgdal)
library(sp)

open_and_sp_transform_shp <- function(shpFilepath, crsInfo){
  x <- rgdal::readOGR(shpFilepath)
  spTransform(x, CRS(crsInfo))
}

format_sp_polygon <- function(SPolygon, crsInfo, idName, typeName){
  SPolygon@data <- data.frame("ID" = idName,
                              "Type" = typeName
                              )
  spTransform(SPolygon, CRS("+init=epsg:4326"))
}

