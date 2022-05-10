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
def assess_and_update_values(df):
    # Lower bounds
    df_mins = df.min(skipna = True)
    
    # Zero bounded variables
    df_maxes = df.max(skipna = True)
    
    vars_with_zero_LB = ['Median_colony_size_Acroporidae'
                             , 'Median_colony_size_Poritidae'
                             , 'CV_colony_size_Acroporidae'
                             , 'CV_colony_size_Poritidae'
                             , 'Poritidae_mean_cover'
                             , 'Acroporidae_mean_cover'
                             , 'H_abund'
                             , 'Parrotfish_abund'
                             , 'Fish_abund'
                             , 'Coral_cover_plating'
                             , 'Coral_cover_all'
                             , 'BlackMarble_2016_3km_geo.3'
                             , 'Long_Term_Kd_Median'
                             , 'Long_Term_Kd_Variability'
                             , 'Three_Week_Kd_Median'
                             , 'Three_week_kd490_90th']
    
    for col in vars_with_zero_LB:
        df[col < 0] = 0
  
df = grid_with_dynamic_predictors.copy(deep = True)
df[df < 0] = 0
    

def winter_condition_offset(df, crw_vs_region_name, offset_value):
    ind = df.index[df.CRW_VS_region == crw_vs_region_name].tolist()
    df.loc[ind, 'Winter_condition'] = df.loc[ind, 'Winter_condition'] - offset_value
    
# grid_with_dynamic_predictors.Hot_snaps.min()
# grid_with_dynamic_predictors.SST_90dMean.min()
# grid_with_dynamic_predictors.Winter_condition.min()
# grid_with_dynamic_predictors.Three_Week_Kd_Median.min()
# grid_with_dynamic_predictors.three_week_kd490_90th.min()

# grid_with_dynamic_predictors.Hot_snaps.max()
# grid_with_dynamic_predictors.SST_90dMean.max()
# grid_with_dynamic_predictors.Winter_condition.max()
# grid_with_dynamic_predictors.Three_Week_Kd_Median.max()
# grid_with_dynamic_predictors.three_week_kd490_90th.max()

# save
grid_with_dynamic_predictors.to_csv('../compiled_data/forecast_inputs/grid_with_dynamic_predictors.csv', index=False)
