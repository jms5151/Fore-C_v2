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

# Setup ---------------------------------------------------------------

# Load module
import runpy

# load functions 
from operational.codes.functions.fun_create_delete_directories import create_dir, delete_dir

# set filepaths
from operational.codes.filepaths import tmp_path

# Create directory for temporary files
create_dir(tmp_path)

# ONLY run first time after cloning repository to unzip files
runpy.run_path(path_name = './operational/codes/Unzip_files.py')

# Co-variates data pre-processing for grid --------------------------- 

# compile NRT & forecasted SST metrics
runpy.run_path(path_name = './operational/codes/Grid_covariates_sst_metrics.py')

# compile seasonal ocean color metrics
runpy.run_path(path_name = './operational/codes/Grid_covariates_ocean_color_dynamic.py')

# compile predictor data
runpy.run_path(path_name = './operational/codes/Grid_concat_dynamic_covariates.py')

# Forecasting --------------------------------------------------------

# run model predictions
runpy.run_path(path_name = './operational/codes/Run_model_forecasts.py')

# create model scenarios
runpy.run_path(path_name = './operational/codes/Create_scenarios.py')

# run scenarios
runpy.run_path(path_name = './operational/codes/Run_model_scenarios.py')

# Create shiny outputs -----------------------------------------------
runpy.run_path(path_name = './operational/codes/Shiny_inputs_aggregate_predictions.py')

runpy.run_path(path_name = './operational/codes/Shiny_inputs_aggregate_scenarios.py')

runpy.run_path(path_name = './operational/codes/Shiny_inputs_update_polygons.py')

# Delete temporary files ---------------------------------------------
delete_dir(tmp_path + 'map_data/')
delete_dir(tmp_path)