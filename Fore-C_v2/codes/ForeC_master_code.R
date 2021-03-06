
###############################################################################
# Master code for University of Hawaii - NOAA Coral Reef Watch Fore-C project #
# Created by Jamie M. Caldwell. Contact: jamie.sziklay@gmail.com              #
# platform       x86_64-w64-mingw32                                           #
# arch           x86_64                                                       #
# os             mingw32                                                      #
# system         x86_64, mingw32                                              #
# year           2021                                                         #
# svn rev        80317                                                        #
# language       R                                                            #
# version.string R version 4.1.0 (2021-05-18)                                 #
# nickname       Camp Pontanezen                                              #
###############################################################################

# rm(list=ls()) #remove previous variable assignments

# Load libraries -----------------------------------------------------
source("./codes/Install_and_load_packages.R")

# Survey and survey co-variate data pre-processing -------------------
### SHOULD CHECK THAT THIS ALL RUNS CORRECTLY ###
# format survey data
source("./codes/Initial_survey_formatting.R")

source("./codes/Calculate_colony_size_metrics_by_island_and_family.R")

source("./codes/Format_survey_data.R")

# creates information for shiny app historical data page 
source("./codes/Format_data_for_historical_map.R") 

source("./codes/Format_unique_survey_properties.R")

# format co-variate data
source("./codes/Survey_covariates_sst_metrics.R")

# this one takes a long time and saves big intermediate data sets
# so it only needs to be re-run in full once
source("codes/Survey_covariates_sst_metrics.R")

source("./codes/Survey_covariates_wave_energy.R")

source("./codes/Survey_covariates_nighttime_lights.R")

source("./codes/Survey_covariates_fish_and_benthos.R")

source("./codes/Survey_covariates_ocean_color.R")

# compile predictor data
source("./codes/Surveys_compile_predictor_data.R")

# SMOTE
source("./codes/Surveys_create_smote_datasets.R")

# Model selection ----------------------------------------------------
# this code takes a long time to run FYI
source("./codes/Model_selection_with_quantile_forests.R")

# summarize results of model selection
source("./codes/Model_selection_summarize_results.R")

# re-run final models and save model objects
source("Models_save_best.R")

# maybe create code to save and compare output from best models
# at each level of smote
# source("./codes/Model_plots_covariates_vs_R2_across_smote_datasets.R")

# plot and save R2 for best and most parsimonious models 
# create csv with R2 and covars for each, to plot against each other
source("./codes/Model_plots_validation.R")

# plot results across smote thresholds
source("./codes/Model_plots_summarize_results_across_smote_datasets.R")

source("./codes/Model_summarize_results_across_smote_datasets.R")

# if creating plots of co-variates, create code here
# source("./codes/Model_plots_covariates.R")

# Create grid and spatial polygons -----------------------------------
source("./codes/Create_forec_reef_grid.R") # add creation date

source("./codes/Create_polygons_reef_grid_5km.R")

source("./codes/Create_polygons_management_areas.R")

source("./codes/List_pixel_IDs_in_polygons.R")

# Co-variates data pre-processing for grid --------------------------- 

# aggregate static variables
source("./codes/Grid_covariates_nighttime_lights.R")

source("./codes/Grid_covariates_fish_and_benthos.R")

source("./codes/Grid_covariates_ocean_color_static.R")

# compile static predictor data
source("./codes/Grid_concat_static_covariates.R")

##### Updating predictions and shiny app starts here #####
# aggregate dynamic variables
source("./codes/Grid_covariates_sst_metrics.R")

# this code is really slow, may want to optimize
source("./codes/Grid_covariates_ocean_color_dynamic.R")

# compile static and dynamic covariates
source("./codes/Grid_concat_dynamic_covariates.R")

# Forecasting --------------------------------------------------------
# After first forecast, each week only need to update two weeks of predictions
source("./codes/Run_model_forecasts.R")

# run scenarios
source("./codes/Create_scenarios.R")

source("./codes/Run_model_scenarios.R")

# Create shiny outputs -----------------------------------------------
source("./codes/Shiny_inputs_aggregate_predictions.R")

source("./codes/Shiny_inputs_aggregate_scenarios.R")

source("./codes/Shiny_inputs_maps.R")

source("./codes/Shiny_inputs_gauge_data.R")

# only needs to be run once
# source("./codes/Shiny_inputs_placeholder_plots.R")

# Create CRW outputs -------------------------------------------------
# this code needs updating
source("./codes/Output_forecasts_for_CRW.R")
