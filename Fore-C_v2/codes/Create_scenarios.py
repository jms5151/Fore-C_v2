# -*- coding: utf-8 -*-
"""
Created on Thu May 26 16:32:21 2022

@author: jamie
"""

import pandas as pd

# load data
grid_with_dynamic_predictors = pd.read_csv('../compiled_data/forecast_inputs/grid_with_dynamic_predictors.csv')
ga_forecast = pd.read_csv('../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ga_forecast.csv')
ws_forecast = pd.read_csv('../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ws_forecast.csv')

# get current data date
current_nowcast_date = grid_with_dynamic_predictors['Date'][grid_with_dynamic_predictors['type'] == "nowcast"].unique().max()

# subset data
nowcast_predictor_date_ind = grid_with_dynamic_predictors.index[(grid_with_dynamic_predictors['Date'] == current_nowcast_date)]
nowcast_predictor_data = grid_with_dynamic_predictors.loc[nowcast_predictor_date_ind]

ga_nowcast_ind = ga_forecast.index[(ga_forecast['Date'] == current_nowcast_date)]
ga_nowcast = ga_forecast.loc[ga_nowcast_ind]

ws_nowcast_ind = ws_forecast.index[(ws_forecast['Date'] == current_nowcast_date)]
ws_nowcast = ws_forecast.loc[ws_nowcast_ind]

