# extract predictor data for each survey point-------------------------------------

# load library
library(tidyverse)

# load predictor data
filenames <- list.files("./compiled_data/survey_covariate_data/", full.names = TRUE)

# load files into global environment
lapply(filenames, load, .GlobalEnv)

# load response data
load("compiled_data/survey_data/GA.RData")
load("compiled_data/survey_data/WS.RData")

# Growth anomalies ---------------------------------------------------------------
GA_data_with_all_predictors <- ga %>%
  left_join(benthic_and_fish_data, by = c("Latitude", "Longitude")) %>%
  left_join(reef_nightlights, by = c("Latitude", "Longitude")) %>%
  left_join(sst_90d, by = c("Date", "Latitude", "Longitude"))  %>%
  left_join(sst_metrics, by = c("Latitude", "Longitude", "Date")) %>%
  left_join(wave_energy, by = c("Latitude", "Longitude")) %>%
  left_join(ocean_color, by = c("Date", "Latitude", "Longitude")) %>%
  left_join(ssta_surveys, by = c("Date", "Latitude", "Longitude"))

# format
GA_data_with_all_predictors$Month <- as.numeric(format(GA_data_with_all_predictors$Date, "%m"))

# separate out surveys that were collected at the exact same 
# location and time as other surveys for validation
GA_data_with_all_predictors$Year_Month <- format(GA_data_with_all_predictors$Date, "%Y-%m")

# save
save(GA_data_with_all_predictors, file = "./compiled_data/survey_data/GA_data_with_all_predictors.RData")

# White syndromes ----------------------------------------------------------------
WS_data_with_all_predictors <- ws %>%
  left_join(benthic_and_fish_data, by = c("Latitude", "Longitude")) %>%
  left_join(wave_energy, by = c("Latitude", "Longitude")) %>%
  left_join(sst_metrics, by = c("Latitude", "Longitude", "Date")) %>%
  left_join(sst_90d, by = c("Date", "Latitude", "Longitude"))  %>%
  left_join(ocean_color, by = c("Date", "Latitude", "Longitude")) %>%
  left_join(ssta_surveys, by = c("Date", "Latitude", "Longitude"))

# format and save
WS_data_with_all_predictors$Month <- as.numeric(format(WS_data_with_all_predictors$Date, "%m"))

# separate out surveys that were collected at the exact same 
# location and time as other surveys for validation
WS_data_with_all_predictors$Year_Month <- format(WS_data_with_all_predictors$Date, "%Y-%m")

# save
save(WS_data_with_all_predictors, file = "./compiled_data/survey_data/WS_data_with_all_predictors.RData")
