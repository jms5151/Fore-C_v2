library(tidyverse)

# load reef grid
load("../compiled_data/spatial_data/grid.RData")

# load predictor data
load("../compiled_data/grid_covariate_data/grid_with_Night_Lights.RData")
load("../compiled_data/grid_covariate_data/grid_with_benthic_and_fish_data.RData")
load("../compiled_data/grid_covariate_data/grid_with_long_term_oc_metrics.RData")
load("../compiled_data/grid_covariate_data/grid_with_wc.RData")

# join data together
grid_with_static_covariates <- reefsDF %>%
  left_join(benthic_and_fish_data, 
            by = c("Latitude", 
                   "Longitude", 
                   "Region", 
                   "ID")) %>%
  left_join(reef_grid_nightlights, 
            by = c("Latitude", 
                   "Longitude", 
                   "Region", 
                   "ID")) %>%
  left_join(reef_grid_lt_oc, 
            by = c("Latitude", 
                   "Longitude", 
                   "Region", 
                   "ID")) %>%
  left_join(reef_grid_wc, by = "ID")

# keep only identifier info and covariates used in final models
source("./codes/Final_covariates_by_disease_and_region.R")

final_covars <- c(ga_gbr_vars,
                  ga_pac_vars,
                  ws_gbr_vars,
                  ws_pac_acr_vars)


final_covars <- unique(final_covars)

final_cols <- colnames(grid_with_static_covariates)[colnames(grid_with_static_covariates) %in% c("Longitude",
                                                                                                 "Latitude",
                                                                                                 "Region",
                                                                                                 "ID",
                                                                                                 "Median_colony_size_Acroporidae",
                                                                                                 "Median_colony_size_Poritidae",
                                                                                                 "CV_colony_size_Acroporidae",
                                                                                                 "CV_colony_size_Poritidae",
                                                                                                 "Poritidae_mean_cover",
                                                                                                 "Acroporidae_mean_cover",
                                                                                                 final_covars)]
grid_with_static_covariates <- grid_with_static_covariates[, final_cols]

save(grid_with_static_covariates, file = "../compiled_data/grid_covariate_data/grid_with_static_covariates.RData")
