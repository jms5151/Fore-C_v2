# -*- coding: utf-8 -*-
"""
Created on Fri Apr 29 12:16:54 2022

@author: jamie
"""
import pandas as pd

# load data
grid_with_static_covariates = pd.read_csv('../compiled_data/grid_covariate_data/grid_with_static_covariates.csv')
reef_grid_sst = pd.read_csv('../compiled_data/grid_covariate_data/grid_with_sst_metrics.csv')
reef_grid_tw_oc = pd.read_csv('../compiled_data/grid_covariate_data/grid_with_three_week_oc_metrics.csv')

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

# add code to screen for unusual values
# this could vary by region and disease type
# many variables have zero lower bound
# upper bounds may be 2 SD above max in survey data?
# Create something like Grid_covariates_sst_metrics.py WC offset function 
# # Lower bounds
# df_mins = df.min(skipna = True)
# # Zero bounded variables
# df_maxes = df.max(skipna = True)

# save
grid_with_dynamic_predictors.to_csv('../compiled_data/forecast_inputs/grid_with_dynamic_predictors.csv', index=False)
