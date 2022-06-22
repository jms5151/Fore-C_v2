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

# Load libraries -----------------------------------------------------
import runpy

# summarize model results
# not sure if runpy is the best way to do this yet
#runpy.run_path(path_name = './codes/Model_summarize_results_across_smote_datasets.py')

# create models ---------------------------------------------------------
# runpy.run_path(path_name = './codes/Model_save_best.py')

# Co-variates data pre-processing for grid --------------------------- 

# compile NRT & forecasted SST metrics
runpy.run_path(path_name = './codes/Grid_covariates_sst_metrics.py')

# compile seasonal ocean color metrics
runpy.run_path(path_name = './codes/Grid_covariates_ocean_color_dynamic.py')

# compile predictor data
runpy.run_path(path_name = './codes/Grid_concat_dynamic_covariates.py')

# Forecasting --------------------------------------------------------

# run model predictions
runpy.run_path(path_name = './codes/Run_model_forecasts.py')

# create model scenarios
runpy.run_path(path_name = './codes/Create_scenarios.py')

# run scenarios
runpy.run_path(path_name = './codes/Run_model_scenarios.py')

# Create shiny outputs -----------------------------------------------
runpy.run_path(path_name = './codes/Shiny_inputs_aggregate_predictions.py')

runpy.run_path(path_name = './codes/Shiny_inputs_aggregate_scenarios.py')

runpy.run_path(path_name = './codes/Shiny_inputs_update_polygons.py')

# Create CRW outputs ? ------------------------------------------------
# source("./codes/Output_forecasts_for_CRW.R")
