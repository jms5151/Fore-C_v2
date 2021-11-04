create_data_frame <- function(fileName, listColumns){
  df <- data.frame(matrix(ncol = length(listColumns), nrow = 0))
  colnames(df) <- listColumns
  write.csv(df, file = fileName, row.names = F)
}