list_polygon_intersection_ids <- function(polygonLargeArea, polygonSmallArea, filePath){
  inter_polygons <- raster::intersect(polygonLargeArea, polygonSmallArea)
  
  data.frame("PolygonID" = inter_polygons$ID.1
             "PixelID" = inter_polygons$ID.2 
             )
  
}
