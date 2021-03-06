# Subset by region, family, predictor variables -----------------------------
subset_df <- function(df, regionGBR, family, yvar, dz_vars){
  # subset by region and family
  if(regionGBR == TRUE){
    x <- subset(df, Region == "GBR")
  } else {
    x <- subset(df, Region != "GBR" & Family == family)
  }
  # subset by response variable and hypothesized disease drivers
  x2 <- x[, c(yvar, 
              "Latitude", 
              "Longitude", 
              "Year_Month", 
              dz_vars)
  ]
  # remove rows with NA
  x2 <- x2[complete.cases(x2), ]
}

# filter psuedo-replicates --------------------------------------------------
filter_pseudo_replicates <- function(df){
  # remove pseudo replicates based on location and time of survey and return df
  df %>%
    group_by(Latitude, Longitude, Year_Month) %>% 
    sample_n(1)  
}
