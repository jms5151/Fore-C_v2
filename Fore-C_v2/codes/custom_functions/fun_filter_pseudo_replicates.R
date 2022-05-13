# filter psuedo-replicates --------------------------------------------------
filter_pseudo_replicates <- function(df){
  # remove pseudo replicates based on location and time of survey and return df
  df %>%
    group_by(Latitude, Longitude, Year_Month) %>% 
    sample_n(1)  
}