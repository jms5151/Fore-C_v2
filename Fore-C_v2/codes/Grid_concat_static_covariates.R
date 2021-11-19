library(tidyverse)

# load reef grid
load("../compiled_data/spatial_data/grid.RData")

# load predictor data
load("../compiled_data/grid_covariate_data/grid_with_Night_Lights.RData")
load("../compiled_data/grid_covariate_data/grid_with_benthic_and_fish_data.RData")
load("../compiled_data/grid_covariate_data/grid_with_long_term_oc_metrics.RData")

# join data together
grid_with_static_predictors <- reefsDF %>%
  left_join(benthic_and_fish_data, by = c("Latitude", "Longitude", "Region", "ID")) %>%
  left_join(reef_grid_nightlights, by = c("Latitude", "Longitude", "Region", "ID")) %>%
  left_join(grid_lt_oc, by = c("Latitude", "Longitude", "Region", "ID"))

save(grid_with_static_predictors, file = "../compiled_data/grid_covariate_data/grid_with_static_predictors.RData")
