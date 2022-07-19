# -*- coding: utf-8 -*-
"""
Use model objects to make predictions for scenarios
Last update: 2022-June-23
"""

# load modules
import pandas as pd # v1.4.2

# set filepaths
from filepaths import tmp_path, shiny_path

# load model objects
from Final_covariates_by_disease_and_region import GA_GBR_Model, GA_Pacific_Model, WS_GBR_Model, WS_Pacific_Model

# load functions
from functions.fun_quant_forest_predict import qf_predict_scenarios
from functions.fun_create_scenarios import adjust_dev_levels

# load scenarios
ga_gbr_scenarios = pd.read_csv(tmp_path + 'ga_gbr_scenarios.csv')
ga_pac_scenarios = pd.read_csv(tmp_path + 'ga_pac_scenarios.csv')
ws_gbr_scenarios = pd.read_csv(tmp_path + 'ws_gbr_scenarios.csv')
ws_pac_scenarios = pd.read_csv(tmp_path + 'ws_pac_scenarios.csv')
 
# output directory path
scenarios_save_dir = shiny_path + 'Scenarios/'

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

# replace response levels of development to correspond with shiny app slider (0-1)
ga_pac_scenario_predictions = adjust_dev_levels(df = ga_pac_scenario_predictions)

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

