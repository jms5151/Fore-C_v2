# filter psuedo-replicates --------------------------------------------------
library(tidyverse)

filter_pseudo_replicates <- function(df){
  # set year and day
  df$Year <- as.numeric(format(df$Date, '%Y'))
  df$Day <- as.numeric(format(df$Date, '%d'))
  # remove pseudo replicates based on location and time of survey and return df
  df <- df %>%
    group_by(Latitude, Longitude, Year, Month) %>% 
    sample_n(1)  
  as.data.frame(df)
}
