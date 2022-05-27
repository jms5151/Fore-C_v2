# -*- coding: utf-8 -*-
"""
Created on Thu May 26 16:27:52 2022

@author: jamie
"""

import pandas as pd
import joblib

# load model objects
GA_GBR_Model = joblib.load("../model_objects/ga_gbr.joblib")
GA_Pacific_Model = joblib.load("../model_objects/ga_pac.joblib")
WS_GBR_Model = joblib.load("../model_objects/ws_gbr.joblib")
WS_Pacific_Model = joblib.load("../model_objects/ws_pac_acr.joblib")
