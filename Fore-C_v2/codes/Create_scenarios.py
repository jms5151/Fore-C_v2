# -*- coding: utf-8 -*-
"""
Created on Thu May 26 16:32:21 2022

@author: jamie
"""

import pandas as pd
import os
import numpy as np

# import custom functions
from codes.custom_functions.fun_create_scenarios import format_scenario_data, baseline_vals, add_scenario_levels

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

# directory path
scenarios_inputs_dir = '../compiled_data/scenarios_inputs/'

# Check whether the specified path exists or not
isExist = os.path.exists(scenarios_inputs_dir)

# Create a new directory if it does not exist 
if not isExist:
  os.makedirs(scenarios_inputs_dir)

# GA GBR ----------------------------------------------------------------------
ga_gbr = format_scenario_data(
    df = ga_nowcast
    , regionGBR = True
    , nowcast_data = nowcast_predictor_data
    , taxa = 'all'
    )

baseline_vals(
    df = ga_gbr
    , covars = ['Fish_abund', 'Coral_cover', 'Long_Term_Kd_Variability']
    , dz_name = 'ga_gbr'
    , regionGBR = True
    )

# create scenarios 
ga_gbr_scenarios = pd.DataFrame()

# Fish abundance
ga_gbr_fish_levels = list(range(400, 801, 50))

ga_gbr_scenarios = add_scenario_levels(
  df = ga_gbr
  , scenario_levels = ga_gbr_fish_levels
  , col_name = 'Fish_abund'
  , response_name = 'Fish'
  , scenarios_df = ga_gbr_scenarios
)

# coral cover
ga_gbr_coral_cover_levels = list(range(5, 96, 10))

ga_gbr_scenarios = add_scenario_levels(
  df = ga_gbr
  , scenario_levels = ga_gbr_coral_cover_levels
  , col_name = 'Coral_cover'
  , response_name = 'Coral cover'
  , scenarios_df = ga_gbr_scenarios
)

# turbidity
ga_gbr_turbidity_levels = np.arange(0.0, 1.1, 0.1).round(1).tolist()

ga_gbr_scenarios = add_scenario_levels(
  df = ga_gbr
  , scenario_levels = ga_gbr_turbidity_levels
  , col_name = 'Long_Term_Kd_Variability'
  , response_name = 'Turbidity'
  , scenarios_df = ga_gbr_scenarios
)


# save
ga_gbr_filepath = scenarios_inputs_dir + 'ga_gbr_scenarios.csv'
ga_gbr_scenarios.to_csv(ga_gbr_filepath, index = False)

# GA Pacific ------------------------------------------------------------------
ga_pac = format_scenario_data(
    df = ga_nowcast
    , regionGBR = False
    , nowcast_data = nowcast_predictor_data
    , taxa = 'Poritidae'
    )

baseline_vals(
    df = ga_pac
    , covars = ['Median_colony_size', 'BlackMarble_2016_3km_geo.3', 'H_abund', 'Long_Term_Kd_Median']
    , dz_name = 'ga_pac'
    , regionGBR = False
    )

# create scenarios ---------
ga_pac_scenarios = pd.DataFrame()

# Colony size
ga_pac_coral_size_levels = list(range(5, 66, 10))

ga_pac_scenarios = add_scenario_levels(
  df = ga_pac
  , scenario_levels = ga_pac_coral_size_levels
  , col_name = 'Median_colony_size'
  , response_name = 'Coral size'
  , scenarios_df = ga_pac_scenarios
)

# coastal development
ga_pac_development_levels = list(range(0, 256, 23))

ga_pac_scenarios = add_scenario_levels(
  df = ga_pac
  , scenario_levels = ga_pac_development_levels
  , col_name = 'BlackMarble_2016_3km_geo.3'
  , response_name = 'Development'
  , scenarios_df = ga_pac_scenarios
)

# herbivorous fish
ga_pac_herb_fish_levels = np.arange(0.1, 0.8, 0.1).round(1).tolist()

ga_pac_scenarios = add_scenario_levels(
  df = ga_pac
  , scenario_levels = ga_pac_herb_fish_levels
  , col_name = 'H_abund'
  , response_name = 'Fish'
  , scenarios_df = ga_pac_scenarios
)

# turbidity
ga_pac_turbidity_levels = np.arange(0.0, 0.5, 0.1).round(1).tolist()

ga_pac_scenarios = add_scenario_levels(
  df = ga_pac
  , scenario_levels = ga_pac_turbidity_levels
  , col_name = 'Long_Term_Kd_Median'
  , response_name = 'Turbidity'
  , scenarios_df = ga_pac_scenarios
)


# save
ga_pac_filepath = scenarios_inputs_dir + 'ga_pac_scenarios.csv'
ga_pac_scenarios.to_csv(ga_pac_filepath, index = False)

# WS GBR ----------------------------------------------------------------------
ws_gbr = format_scenario_data(
    df = ws_nowcast
    , regionGBR = True
    , nowcast_data = nowcast_predictor_data
    , taxa = 'plating'
    )

baseline_vals(
    df = ws_gbr
    , covars = ['Coral_cover', 'Fish_abund', 'Three_Week_Kd_Variability']
    , dz_name = 'ws_gbr'
    , regionGBR = True
    )

# create scenarios 
ws_gbr_scenarios = pd.DataFrame()

# coral cover
ws_gbr_coral_cover_levels = list(range(5, 86, 10))

ws_gbr_scenarios = add_scenario_levels(
  df = ws_gbr
  , scenario_levels = ws_gbr_coral_cover_levels
  , col_name = 'Coral_cover'
  , response_name = 'Coral cover'
  , scenarios_df = ws_gbr_scenarios
)

# Fish abundance
ws_gbr_fish_levels = list(range(400, 801, 50))

ws_gbr_scenarios = add_scenario_levels(
  df = ws_gbr
  , scenario_levels = ws_gbr_fish_levels
  , col_name = 'Fish_abund'
  , response_name = 'Fish'
  , scenarios_df = ws_gbr_scenarios
)

# turbidity
ws_gbr_turbidity_levels = np.arange(0.0, 1.1, 0.1).round(1).tolist()

ws_gbr_scenarios = add_scenario_levels(
  df = ws_gbr
  , scenario_levels = ws_gbr_turbidity_levels
  , col_name = 'Three_Week_Kd_Variability'
  , response_name = 'Turbidity'
  , scenarios_df = ws_gbr_scenarios
)

# save
ws_gbr_filepath = scenarios_inputs_dir + 'ws_gbr_scenarios.csv'
ws_gbr_scenarios.to_csv(ws_gbr_filepath, index = False)

# WS Pacific ------------------------------------------------------------------
ws_pac = format_scenario_data(
    df = ws_nowcast
    , regionGBR = False
    , nowcast_data = nowcast_predictor_data
    , taxa = 'Acroporidae'
    )

baseline_vals(
    df = ws_pac
    , covars = ['Median_colony_size', 'Parrotfish_abund', 'Long_Term_Kd_Median', 'H_abund', 'mean_cover']
    , dz_name = 'ws_pac'
    , regionGBR = False
    )

# create scenarios ---------
ws_pac_scenarios = pd.DataFrame()

# colony size
ws_pac_coral_size_levels = list(range(5, 66, 10))

ws_pac_scenarios = add_scenario_levels(
  df = ws_pac
  , scenario_levels = ws_pac_coral_size_levels
  , col_name = 'Median_colony_size'
  , response_name = 'Coral size'
  , scenarios_df = ws_pac_scenarios
  )

# Parrotfish density
ws_pac_parrotfish_levels = np.arange(0.0, 0.07, 0.01).round(1).tolist()

ws_pac_scenarios = add_scenario_levels(
  df = ws_pac
  , scenario_levels = ws_pac_parrotfish_levels
  , col_name = 'Parrotfish_abund'
  , response_name = 'Parrotfish density'
  , scenarios_df = ws_pac_scenarios
  )

# turbidity
ws_pac_turbidity_levels = np.arange(0.0, 2.1, 0.1).round(1).tolist()

ws_pac_scenarios = add_scenario_levels(
  df = ws_pac
  , scenario_levels = ws_pac_turbidity_levels
  , col_name = 'Long_Term_Kd_Median'
  , response_name = 'Turbidity'
  , scenarios_df = ws_pac_scenarios
)

# coral cover
ws_pac_coral_cover_levels = list(range(5, 66, 10))

ws_pac_scenarios = add_scenario_levels(
  df = ws_pac
  , scenario_levels = ws_pac_coral_cover_levels
  , col_name = 'mean_cover'
  , response_name = 'Coral cover'
  , scenarios_df = ws_pac_scenarios
)

# herbivorous fish
ws_pac_herb_fish_levels = np.arange(0.0, 0.7, 0.1).round(1).tolist()

ws_pac_scenarios = add_scenario_levels(
  df = ws_pac
  , scenario_levels = ws_pac_herb_fish_levels
  , col_name = 'H_abund'
  , response_name = 'Herb. fish'
  , scenarios_df = ws_pac_scenarios
)

# save
ws_pac_filepath = scenarios_inputs_dir + 'ws_pac_scenarios.csv'
ws_pac_scenarios.to_csv(ws_pac_filepath, index = False)

