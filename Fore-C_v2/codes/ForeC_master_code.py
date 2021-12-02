# -*- coding: utf-8 -*-
"""
Master code for University of Hawaii - NOAA Coral Reef Watch Fore-C project
Created by Jamie M. Caldwell. Contact: jamie.sziklay@gmail.com
# platform       x86_64-w64-mingw32
# arch           x86_64
# os             mingw32
# system         x86_64, mingw32
# language       Python
# version.string Python version 3.8.8 (2021-12-02)
"""

# # Load libraries -----------------------------------------------------
# source("./codes/Install_and_load_packages.R")
# pip install dplython
import os
import pandas as pd
import dplython

# create model ---------------------------------------------------------

library(tidyverse)

# load data
x = pd.read_csv("../model_selection_summary_results/qf_smote_summary.csv")

# https://stmorse.github.io/journal/tidyverse-style-pandas.html
# format data for plotting
# x2 = x %>%
#   filter(selection == "parsimonious_best") %>%
#   group_by(Disease_type) %>%
#   filter(AdjR2_withheld_sample == max(AdjR2_withheld_sample))

x2 = (x 
  .filter([selection == "parsimonious_best"]) 
  .groupby(Disease_type) 
  .filter([AdjR2_withheld_sample == AdjR2_withheld_sample.max])
  )


# # Co-variates data pre-processing for grid --------------------------- 

# source("./codes/Grid_covariates_sst_metrics.R")

## not sure these are needed because they are not changing
# source("./codes/Grid_covariates_nighttime_lights.R")

# source("./codes/Grid_covariates_fish_and_benthos.R")
##

# source("./codes/Grid_covariates_ocean_color.R")

# # compile predictor data
# source("./codes/Grid_concat_static_covariates.R")

# source("./codes/Grid_concat_dynamic_covariates.R")

# # Forecasting --------------------------------------------------------
# # After first forecast, each week only need to update two weeks of predictions
# source("./codes/Run_model_forecasts.R")

# # create code to update forecasts?
# # source("./codes/Update_model_forecasts.R")

# # run scenarios
# # source("./codes/Run_scenarios.R")

# # Create shiny outputs -----------------------------------------------
# source("./codes/Shiny_inputs_aggregate_predictions.R")

# source("./codes/Shiny_inputs_update_polygons.R")
