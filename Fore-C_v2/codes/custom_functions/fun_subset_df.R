# Subset by region, family, predictor variables -----------------------------
subset_df <- function(df, regionGBR, family, dz_vars){
  # subset by region and family
  if(regionGBR == TRUE){
    x <- subset(df, Region == 'GBR')
  } else {
    x <- subset(df, Region != 'GBR' & Family == family)
  }
  # subset by response variable and hypothesized disease drivers
  x2 <- x[, c(
    'Latitude'
    , 'Longitude'
    , 'Date'
    , dz_vars
    )
  ]
  # remove rows with NA
  x2[complete.cases(x2), ]
  
}
