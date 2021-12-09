# -*- coding: utf-8 -*-
"""
Created on Thu Dec  9 11:27:48 2021

@author: jamie
"""

import os
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
import joblib
import runpy

# import custom predict function
from codes.custom_functions.fun_quant_forest_predict import qf_predict

# import lists of final models covariates 
from codes.Final_covariates_by_disease_and_region import ga_gbr_vars, ws_gbr_vars, ga_pac_vars, ws_pac_acr_vars

# open model objects
GA_GBR_Model = joblib.load("../model_objects/ga_gbr_parsimonious_best_smote_0.joblib")
# GA_Pacific_Model = joblib.load("../model_objects/ga_pac_parsimonious_best_smote_5.joblib")
WS_GBR_Model = joblib.load("../model_objects/ws_gbr_parsimonious_best_smote_0.joblib")
# WS_Pacific_Model = joblib.load("../model_objects/ws_pac_acr_parsimonious_best_smote_0.joblib")

# set up directory filepaths
forecast_dir = "../compiled_data/forecast_inputs/"

# list all csv files in forecast directory
all_files = os.listdir(forecast_dir)
csv_files = list(filter(lambda f: f.endswith('.csv'), all_files))

# should run in parallel for faster processing
for i in len(csv_files):
    # open file
    dfx = pd.read_csv(forecast_dir + csv_files[i])
    # # GA Pacific
    # qf_predict(df = dfx,
    #            regionGBRtrue = FALSE,
    #            covars = ga_pac_covars,
    #            family = "Poritidae",
    #            final_mod = GA_Pacific_Model,
    #             covars = ga_pac_vars,
    #            name = "ga_pac",
    #            fileName2 = csv_files[i])
    # # WS Pacific
    # qf_predict(df = dfx,
    #            regionGBRtrue = FALSE,
    #            family = "Acroporidae",
    #            final_mod = WS_Pacific_Model,
    #             covars = ws_pac_acr_vars,
    #            name = "ws_pac",
    #            fileName2 = csv_files[i])
    # GA GBR
    qf_predict(df = dfx,
               regionGBRtrue = True,
               family = "",
               final_mod = GA_GBR_Model,
               covars = ga_gbr_vars,
               name = "ga_gbr",
               fileName2 = csv_files[i])
    # WS GBR
    qf_predict(df = dfx,
               regionGBRtrue = TRUE,
               family = "",
               final_mod = WS_GBR_Model,
               covars = ws_gbr_vars,
               name = "ws_gbr",
               fileName2 = csv_files[i])
