list_polygon_intersection_ids <- function(polygonLargeArea, polygonSmallArea, filePath){
  inter_polygons <- raster::intersect(polygonLargeArea, polygonSmallArea)
  
  # RPolygonID <- inter_polygons$ID.1
  # RPixelID <- inter_polygons$ID.2
  # 
  data.frame("PolygonID" = inter_polygons$ID.1, #RPolygonID, #
             "PixelID" = inter_polygons$ID.2 #RPixelID
             )
  
}
