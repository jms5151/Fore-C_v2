# -*- coding: utf-8 -*-
"""
Load model objects and list covariates in each model
Last update: 2022-June-23
"""

# load module
import joblib # v1.1.0

# set filepaths
from filepaths import models_path

# load model objects
GA_GBR_Model = joblib.load(models_path + 'ga_gbr.joblib')
GA_Pacific_Model = joblib.load(models_path + 'ga_pac.joblib')
WS_GBR_Model = joblib.load(models_path + 'ws_gbr.joblib')
WS_Pacific_Model = joblib.load(models_path + 'ws_pac_acr.joblib')

# Growth anomalies GBR 
ga_gbr_vars = GA_GBR_Model.feature_names_in_

# Growth anomalies Pacific
ga_pac_vars = GA_Pacific_Model.feature_names_in_

# White syndreoms GBR 
ws_gbr_vars = WS_GBR_Model.feature_names_in_

# White syndromes Pacific (Acroporidae)
ws_pac_acr_vars = WS_Pacific_Model.feature_names_in_


