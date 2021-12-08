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
# ws_pac_acr = robjects.r['load']("../compiled_data/survey_data/smote_datasets/ws_pac_acr_with_predictors_smote_0_prev.RData")
# ws_pac_acr = pyreadr.read_r("../compiled_data/survey_data/smote_datasets/ws_pac_acr_with_predictors_smote_0_prev.RData")
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


# load, no need to initialize the loaded_rf
# loaded_rf = joblib.load(fileName)
# loaded_rf.predict(X_test)

# pred_Q = pd.DataFrame()

# for pred in rf.estimators_:
#  temp = pd.Series(pred.predict(X_test).round(2))
#  pred_Q = pd.concat([pred_Q,temp],axis=1)

# pred_Q.head()

# RF_actual_pred = pd.DataFrame()

# quantiles = [0.01, 0.05, 0.50, 0.95 , 0.99] # in R we used 0.05, 0.75, 0.95, but maybe we want 0.5, 0.75, 0.95?

# for q in quantiles:
#     s = pred_Q.quantile(q = q, axis = 1)
#     RF_actual_pred = pd.concat([RF_actual_pred, s], axis = 1, sort = False)
   
# RF_actual_pred.columns=quantiles
# RF_actual_pred['actual'] = Y_test
# RF_actual_pred['interval'] = RF_actual_pred[np.max(quantiles)] - RF_actual_pred[np.min(quantiles)]
# RF_actual_pred = RF_actual_pred.sort_values('interval')
# RF_actual_pred = RF_actual_pred.round(2)
# RF_actual_pred


# # Get the R-squared
# from sklearn import metrics
# r2 = metrics.r2_score(RF_actual_pred['actual'], RF_actual_pred[0.5]).round(2)
# print('R2 score is {}'.format(r2) )  # 0.81

# # Get the correct percentage
# def correctPcnt(df):
#     correct = 0
#     obs = df.shape[0]
#     for i in range(obs):
#         if df.loc[i,0.01] <= df.loc[i,'actual'] <= df.loc[i,0.99]:
#             correct += 1
#     print(correct/obs)
    
# correctPcnt(RF_actual_pred) # 0.9509


# # Show the intervals
# def showIntervals(df):    
#     plt.plot(df['actual'],'go',markersize=3,label='Actual')
#     plt.fill_between(
#         np.arange(df.shape[0]), df[0.01], df[0.99], alpha=0.5, color="r",
#         label="Predicted interval")
#     plt.xlabel("Ordered samples.")
#     plt.ylabel("Values and prediction intervals.")
#     plt.xlim([0, 100])
#     plt.ylim([-4, 6])
#     plt.legend()
#     plt.show()
    
# showIntervals(RF_actual_pred) 
# another option:
#https://stackoverflow.com/questions/51483951/quantile-random-forests-from-scikit-garden-very-slow-at-making-predictions