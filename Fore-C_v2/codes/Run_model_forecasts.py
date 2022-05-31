# -*- coding: utf-8 -*-
"""
Created on Thu Dec  9 11:27:48 2021

@author: jamie
"""

import pandas as pd
import joblib

# import custom predict function
from codes.custom_functions.fun_quant_forest_predict import qf_predict_new, update_forecasts, combine_regional_forecasts

# load model objects
GA_GBR_Model = joblib.load("../model_objects/ga_gbr.joblib")
GA_Pacific_Model = joblib.load("../model_objects/ga_pac.joblib")
WS_GBR_Model = joblib.load("../model_objects/ws_gbr.joblib")
WS_Pacific_Model = joblib.load("../model_objects/ws_pac_acr.joblib")

# load predictor data
covariates = pd.read_csv('../compiled_data/forecast_inputs/grid_with_dynamic_predictors.csv')

# forecast id variables
forecast_id_vars = ["ID", "Latitude", "Longitude", "Region", "Date", "ensemble", "type"]

# run forecasts by region-disease --------------------------------------------
ga_gbr_forecasts = qf_predict_new(
    df = covariates
    , regionGBRtrue = True
    , family = 'all'
    , final_mod = GA_GBR_Model
    , id_vars = forecast_id_vars
    )

ga_pac_forecasts = qf_predict_new(
    df = covariates
    , regionGBRtrue = False
    , family = 'Poritidae'
    , final_mod = GA_Pacific_Model
    , id_vars = forecast_id_vars
    )

ws_pac_forecasts = qf_predict_new(
    df = covariates
    , regionGBRtrue = False
    , family = 'Acroporidae'
    , final_mod = WS_Pacific_Model
    , id_vars = forecast_id_vars
    )

ws_gbr_forecasts = qf_predict_new(
    df = covariates
    , regionGBRtrue = True
    , family = 'plating'
    , final_mod = WS_GBR_Model
    , id_vars = forecast_id_vars
    )

# combine data and format
ga_forecast = combine_regional_forecasts(gbr_df = ga_gbr_forecasts, pac_df = ga_pac_forecasts)
ws_forecast = combine_regional_forecasts(gbr_df = ws_gbr_forecasts, pac_df = ws_pac_forecasts)
                    
# add alert levels for GA -----------------------------------------------------
# No risk
ga_forecast['drisk'] = 0

# Watch
ga_watch_ind = ga_forecast.index[(ga_forecast['value'] > 5) & (ga_forecast['value'] <= 10)].tolist()
ga_forecast.loc[ga_watch_ind , 'drisk'] = 1

# Warning
ga_warning_ind = ga_forecast.index[(ga_forecast['value'] > 10) & (ga_forecast['value'] <= 15)].tolist()
ga_forecast.loc[ga_warning_ind, 'drisk'] = 2

# Alert level 1
ga_alert1_ind = ga_forecast.index[(ga_forecast['value'] > 15) & (ga_forecast['value'] <= 25)].tolist()
ga_forecast.loc[ga_alert1_ind , 'drisk'] = 3

# Alert level 2
ga_alert2_ind = ga_forecast.index[(ga_forecast['value'] > 25)].tolist()
ga_forecast.loc[ga_alert2_ind, 'drisk'] = 4

# add alert levels for WS -----------------------------------------------------
# No risk
ws_forecast['drisk'] = 0

# Watch
ws_watch_ind = ws_forecast.index[(ws_forecast['value'] > 1) & (ws_forecast['value'] <= 5)].tolist()
ws_forecast.loc[ws_watch_ind , 'drisk'] = 1

# Warning
ws_warning_ind = ws_forecast.index[(ws_forecast['value'] > 5) & (ws_forecast['value'] <= 10)].tolist()
ws_forecast.loc[ws_warning_ind, 'drisk'] = 2

# Alert level 1
ws_alert1_ind_gbr = ws_forecast.index[(ws_forecast['Region'] == 'gbr') & (ws_forecast['value'] > 10) & (ws_forecast['value'] <= 20)].tolist()
ws_alert1_ind_pac = ws_forecast.index[(ws_forecast['Region'] != 'gbr') & (ws_forecast['value'] > 10) & (ws_forecast['value'] <= 15)].tolist()
ws_forecast.loc[ws_alert1_ind_gbr, 'drisk'] = 3
ws_forecast.loc[ws_alert1_ind_pac, 'drisk'] = 3

# Alert level 2
ws_alert2_ind_gbr = ws_forecast.index[(ws_forecast['Region'] == 'gbr') & (ws_forecast['value'] > 20)].tolist()
ws_alert2_ind_pac = ws_forecast.index[(ws_forecast['Region'] != 'gbr') & (ws_forecast['value'] > 15)].tolist()
ws_forecast.loc[ws_alert2_ind_gbr, 'drisk'] = 4
ws_forecast.loc[ws_alert2_ind_pac, 'drisk'] = 4

# Check if previous predictions exist, and if so, update forecasts ------------
ga_filepath = '../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ga_forecast.csv'
ws_filepath = '../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ws_forecast.csv'

ga_forecast_updated = update_forecasts(df_filepath = ga_filepath, new_df = ga_forecast)
ws_forecast_updated = update_forecasts(df_filepath = ws_filepath, new_df = ws_forecast)

# save
ga_forecast_updated.to_csv(ga_filepath, index = False)
ws_forecast_updated.to_csv(ws_filepath, index = False)

