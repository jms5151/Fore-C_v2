# -*- coding: utf-8 -*-
"""
Created on Wed Dec  8 11:36:52 2021

@author: jamie
"""

# in terminal
# pip install setuptools numpy scipy scikit-learn cython
# pip install scikit-garden

import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
import pyreadr
import rpy2.robjects as robjects
import joblib
# semi-hard code initially
x = pd.read_csv('../model_selection_summary_results/parsimonious_best_models_by_disease_and_region.csv')

# information about first row
#x.iloc[3]

# had to update output to csv
ga_pac = pd.read_csv("../compiled_data/survey_data/smote_datasets/ga_pac_with_predictors_smote_5_prev.csv")
ga_gbr = pd.read_csv("../compiled_data/survey_data/smote_datasets/ga_gbr_with_predictors_smote_0_count.csv")
ws_gbr = pd.read_csv("../compiled_data/survey_data/smote_datasets/ws_gbr_with_predictors_smote_0_count.csv")
ws_pac_acr = pd.read_csv("../compiled_data/survey_data/smote_datasets/ws_pac_acr_with_predictors_smote_0_prev.csv")

# make sure these are in the same order
cdz_names = x['Disease_type']
cdz = [ws_pac_acr, ga_pac, ws_gbr, ga_gbr]
smote_vals = x["Smote_threshold"]

# set where model objects will be stored
model_objects_dir = "../model_objects/"

# create and save models
for i in range(4):
    df = cdz[i]
    # determine response variables based on whether or not column names include "p"
    if 'p' in df.columns:
        response = np.array(df['p'])
    else:
        response = np.array(df['Y'])
    # list covariates
    df_covars = x.iloc[i].Covariates.split(", ")
    df2 = df[df_covars]
    # split data into training and testing
    X_train, X_test, Y_train, Y_test = train_test_split(df2, response, test_size = 0.25, random_state = 5)
    # create model
    # n_estimators is number of trees, goes slower as number goes up
    qrf = RandomForestRegressor(n_estimators = 200, random_state = 0, min_samples_split = 10)
    qrf.fit(X_train, Y_train)
    # save
    fileName = model_objects_dir + cdz_names[i] + str('_parsimonious_best_smote_') + str(smote_vals[i]) + str('.joblib')
    joblib.dump(qrf, fileName)
