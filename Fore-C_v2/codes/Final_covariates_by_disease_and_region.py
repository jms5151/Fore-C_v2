# -*- coding: utf-8 -*-
"""
Created on Thu Dec  9 12:16:50 2021

@author: jamie
"""

import joblib

# open final model objects
GA_GBR_Model = joblib.load("../model_objects/ga_gbr.joblib")
GA_Pacific_Model = joblib.load("../model_objects/ga_pac.joblib")
WS_GBR_Model = joblib.load("../model_objects/ws_gbr.joblib")
WS_Pacific_Model = joblib.load("../model_objects/ws_pac_acr.joblib")

# Growth anomalies GBR 
ga_gbr_vars = GA_GBR_Model.feature_names_in_

# Growth anomalies Pacific
ga_pac_vars = GA_Pacific_Model.feature_names_in_

# White syndreoms GBR 
ws_gbr_vars = WS_GBR_Model.feature_names_in_

# White syndromes Pacific (Acroporidae)
ws_pac_acr_vars = WS_Pacific_Model.feature_names_in_


