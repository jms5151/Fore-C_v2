# -*- coding: utf-8 -*-
"""
Combine all predictor data for models
Last update: 2022-Apr-29
"""
# load module
import pandas as pd # v1.4.2

# set filepaths
from filepaths import tmp_path, input_path

# load data
grid_with_static_covariates = pd.read_csv(input_path + 'grid_with_static_covariates.csv')
reef_grid_sst = pd.read_csv(tmp_path + 'grid_with_sst_metrics.csv')
reef_grid_tw_oc = pd.read_csv(tmp_path + 'grid_with_three_week_oc_metrics.csv')

# combine data
grid_with_dynamic_predictors = reef_grid_sst.merge(
    grid_with_static_covariates
    , on = ['ID', 'Longitude', 'Latitude', 'Region']
    , how = 'right')

grid_with_dynamic_predictors = grid_with_dynamic_predictors.merge(
    reef_grid_tw_oc
    # check that these are the overlapping columns
    , on = ['ID', 'Date']
    , how = 'right')

# Add month as an integer
grid_with_dynamic_predictors['Date'] = pd.to_datetime(grid_with_dynamic_predictors['Date'], format = '%Y-%m-%d')
months = [x.month for x in grid_with_dynamic_predictors['Date'].tolist()]
grid_with_dynamic_predictors['Month'] = months

# save
grid_with_dynamic_predictors.to_csv(tmp_path + 'grid_with_dynamic_predictors.csv', index = False)
