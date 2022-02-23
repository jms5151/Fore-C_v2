library(tidyverse)

# load data
load("../compiled_data/grid_covariate_data/grid_with_static_covariates.RData")
load("../compiled_data/grid_covariate_data/grid_with_sst_metrics.RData")
load("../compiled_data/grid_covariate_data/grid_with_three_week_oc_metrics.RData")

# combine data
grid_with_dynamic_predictors <- reef_grid_sst %>%
  left_join(reef_grid_tw_oc) %>%
  left_join(grid_with_static_covariates) %>%
  mutate("Month" = as.numeric(format(Date, "%m")))

# save
save(grid_with_dynamic_predictors, file = "../compiled_data/forecast_inputs/grid_with_dynamic_predictors.RData")