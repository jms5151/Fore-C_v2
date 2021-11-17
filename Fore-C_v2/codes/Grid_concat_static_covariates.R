library(tidyverse)
library(zoo)

# load reef grid
load("Compiled_data/grid.RData")

# load predictor data
load("Compiled_data/grid_with_Night_Lights.RData")
load("Compiled_data/grid_with_benthic_and_fish_data.RData")
# load("Compiled_data/grid_with_wave_energy.RData") # exclude
load("Compiled_data/grid_with_static_ocean_color_metrics.RData")

# join data together
grid_with_static_predictors <- reefsDF %>%
  left_join(benthic_and_fish_data, by = c("Latitude", "Longitude", "Region", "ID")) %>%
  left_join(reef_grid_nightlights, by = c("Latitude", "Longitude", "Region", "ID")) %>%
  # left_join(wave_energy, by = c("Latitude", "Longitude", "Region", "ID")) %>%
  left_join(ocean_color_static_metrics, by = c("Latitude", "Longitude", "Region", "ID"))

save(grid_with_static_predictors, file = "Compiled_data/grid_with_static_predictors.RData")
