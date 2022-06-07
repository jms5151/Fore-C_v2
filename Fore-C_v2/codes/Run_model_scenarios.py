# -*- coding: utf-8 -*-
"""
Created on Thu May 26 16:27:52 2022

@author: jamie
"""

import pandas as pd
import os

# load model objects
from codes.Final_covariates_by_disease_and_region import GA_GBR_Model, GA_Pacific_Model, WS_GBR_Model, WS_Pacific_Model
from codes.custom_functions.fun_quant_forest_predict import qf_predict_scenarios

# load scenarios
ga_gbr_scenarios = pd.read_csv('../compiled_data/scenarios_inputs/ga_gbr_scenarios.csv')
ga_pac_scenarios = pd.read_csv('../compiled_data/scenarios_inputs/ga_pac_scenarios.csv')
ws_gbr_scenarios = pd.read_csv('../compiled_data/scenarios_inputs/ws_gbr_scenarios.csv')
ws_pac_scenarios = pd.read_csv('../compiled_data/scenarios_inputs/ws_pac_scenarios.csv')
 
# output directory path
# scenarios_save_dir = '../compiled_data/scenarios_outputs/'
scenarios_save_dir = '../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/'

# Check whether the specified path exists or not
isExist = os.path.exists(scenarios_save_dir)

# Create a new directory if it does not exist 
if not isExist:
  os.makedirs(scenarios_save_dir)

# list scenario id variables
scenarios_id_vars = ['ID', 'Latitude', 'Longitude', 'Region', 'predicted', 'Response', 'Response_level']

# run scenarios ---------------------------------------------------------------

# GA GBR ---------------
ga_gbr_scenario_predictions = qf_predict_scenarios(
    df = ga_gbr_scenarios
    , regionGBRtrue = True
    , family = 'all'
    , final_mod = GA_GBR_Model
    , id_vars = scenarios_id_vars
    )

ga_gbr_filepath = scenarios_save_dir + 'ga_gbr_scenarios.csv'
ga_gbr_scenario_predictions.to_csv(ga_gbr_filepath, index = False)


# GA Pacific -----------
ga_pac_scenario_predictions = qf_predict_scenarios(
    df = ga_pac_scenarios
    , regionGBRtrue = False
    , family = 'Poritidae'
    , final_mod = GA_Pacific_Model
    , id_vars = scenarios_id_vars
    )

ga_pac_filepath = scenarios_save_dir + 'ga_pac_scenarios.csv'
ga_pac_scenario_predictions.to_csv(ga_pac_filepath, index = False)

# WS GBR ---------------
ws_gbr_scenario_predictions = qf_predict_scenarios(
    df = ws_gbr_scenarios
    , regionGBRtrue = True
    , family = 'plating'
    , final_mod = WS_GBR_Model
    , id_vars = scenarios_id_vars
    )

ws_gbr_filepath = scenarios_save_dir + 'ws_gbr_scenarios.csv'
ws_gbr_scenario_predictions.to_csv(ws_gbr_filepath, index = False)


# WS Pacific -----------
ws_pac_scenario_predictions = qf_predict_scenarios(
    df = ws_pac_scenarios
    , regionGBRtrue = False
    , family = 'Acroporidae'
    , final_mod = WS_Pacific_Model
    , id_vars = scenarios_id_vars
    )

ws_pac_filepath = scenarios_save_dir + 'ws_pac_scenarios.csv'
ws_pac_scenario_predictions.to_csv(ws_pac_filepath, index = False)

