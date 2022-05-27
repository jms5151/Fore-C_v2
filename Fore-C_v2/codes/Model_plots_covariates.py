# -*- coding: utf-8 -*-
"""
Created on Fri May 27 11:48:50 2022

@author: jamie
"""
import joblib
import pandas as pd
import matplotlib.pyplot as plt

GA_GBR_Model = joblib.load("../model_objects/ga_gbr.joblib")
GA_Pacific_Model = joblib.load("../model_objects/ga_pac.joblib")
WS_GBR_Model = joblib.load("../model_objects/ws_gbr.joblib")
WS_Pacific_Model = joblib.load("../model_objects/ws_pac_acr.joblib")

# plot node impurity
X = pd.DataFrame()
X['covars'] = WS_Pacific_Model.feature_importances_
X['names'] = WS_Pacific_Model.feature_names_in_

plt.scatter(X.covars * 100, X.names, color = 'black')
