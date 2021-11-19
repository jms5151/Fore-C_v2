library(tidyverse)

# load data
load("../compiled_data/grid_covariate_data/grid_with_static_covariates.RData")
load("../compiled_data/grid_covariate_data/grid_with_sst_metrics.RData")
load("../compiled_data/grid_covariate_data/grid_with_three_week_oc_metrics.RData")

# combine data
grid_with_dynamic_predictors <- reef_grid_sst %>%
  left_join(reef_grid_tw_oc,
            by = c("ID", 
                   "Date")) %>%
  left_join(grid_with_static_covariates,
            by = c("ID", 
                   "Longitude", 
                   "Latitude", 
                   "Region"))

# create vector of prediction weeks
prediction_dates <- sort(unique(grid_with_dynamic_predictors$Date))
prediction_week <- seq(from = 1,
                       to = length(prediction_dates),
                       by = 1)

# save data separately by prediction week and ensemble
forecast_data_dir <- "../compiled_data/forecast_data/"

# The split function is faster and more concise, but I'm not sure there 
# is a python equivalent, so just using a loop here, still fairly fast
for(i in 1:length(prediction_dates)){
  x <- subset(grid_with_dynamic_predictors, Date == prediction_dates[i])
  ensembles <- unique(x$ensemble)
  for(j in ensembles){ # ensemble
    weekly_grid <- subset(x, ensemble == j)
    save(weekly_grid,
         file = paste0(forecast_data_dir, 
                       "grid_week_", 
                       prediction_week[i],
                       "_ensemble_",
                       j))
  }
}
