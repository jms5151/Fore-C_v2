# Filter pseudo replicated suveys from main data, save for future validation
# load library
library(tidyverse)

# load data
load("../compiled_data/survey_data/GA_data_with_all_predictors.RData")
load("../compiled_data/survey_data/WS_data_with_all_predictors.RData")

# source co-variates to test
source("codes/Initial_covariates_to_test_by_disease_and_region.R")

# Growth anomalies ---------------------------------------------------------------

# sample 1 row from unique location and year
GA_data_with_all_predictors_slim <- GA_data_with_all_predictors %>%
  group_by(Latitude, Longitude, Year_Month) %>% 
  sample_n(1)

save(GA_data_with_all_predictors_slim,
     file = "../compiled_data/survey_data/GA_data_with_all_predictors_slim.RData")

# take the opposite for validation set
GA_data_with_all_predictors_pseudo_replicates <- setdiff(GA_data_with_all_predictors, GA_data_with_all_predictors_slim)

# save data
save(GA_data_with_all_predictors_pseudo_replicates, 
     file = "../compiled_data/survey_data/GA_data_with_all_predictors_pseudo_replicates.RData")


# White syndromes ----------------------------------------------------------------

# sample 1 row from unique location and year
WS_data_with_all_predictors_slim <- WS_data_with_all_predictors %>%
  group_by(Latitude, Longitude, Year_Month) %>% 
  sample_n(1)

save(WS_data_with_all_predictors_slim,
     file = "../compiled_data/survey_data/WS_data_with_all_predictors_slim.RData")

# take the opposite for validation set
WS_data_with_all_predictors_pseudo_replicates <- setdiff(WS_data_with_all_predictors, WS_data_with_all_predictors_slim)

# save data
save(WS_data_with_all_predictors_pseudo_replicates, 
     file = "../compiled_data/survey_data/WS_data_with_all_predictors_pseudo_replicates.RData")


