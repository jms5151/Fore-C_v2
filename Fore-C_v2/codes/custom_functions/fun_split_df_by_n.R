split_df_by_n <- function(nrowSize, df){
  chunk <- nrowSize
  n <- nrow(df)
  r  <- rep(1:ceiling(n/chunk),each=chunk)[1:n]
  split(df, r)
}