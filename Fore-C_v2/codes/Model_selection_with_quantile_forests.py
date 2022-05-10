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
import joblib

# semi-hard code initially
x = pd.read_csv('../model_selection_summary_results/parsimonious_best_models_by_disease_and_region.csv')

# information about first row
#x.iloc[3]

# make sure these are in the same order
cdz_names = x['Disease_type']
smote_vals = x["Smote_threshold"]

# set where model objects will be stored
model_objects_dir = "../model_objects/"

# create and save models
for i in range(4):
    # open smote dataset
    smote_df_filepath = str('../compiled_data/survey_data/smote_datasets/') + cdz_names[i] + str('_with_predictors_smote_') + str(smote_vals[i])
    if 'gbr' in cdz_names[i]:
        smote_df_filepath = smote_df_filepath + str('_count.csv')
    else:
        smote_df_filepath = smote_df_filepath + str('_prev.csv')        
    df = pd.read_csv(smote_df_filepath)
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
    
    # # plots: these take awhile to produce and aren't needed so comment in/out as desired
    # fig, ax = plt.subplots(figsize=(14, 10))
    # ax.set_title(cdz_names[i])
    # pdp_plot = PartialDependenceDisplay.from_estimator(qrf, df2, df_covars, ax = ax)
    
    # fig2, ax2 = plt.subplots(figsize=(14, 10))
    # ax2.set_title(cdz_names[i])
    # pdp_plot2 = PartialDependenceDisplay.from_estimator(qrf, df2, df_covars, ax = ax2, kind = 'both')

