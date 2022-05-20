# -*- coding: utf-8 -*-
"""
Created on Fri May 20 12:53:12 2022

@author: jamie
"""

# in terminal
# pip install setuptools numpy scipy scikit-learn cython
# pip install scikit-garden

import pandas as pd
from sklearn.ensemble import RandomForestRegressor
import joblib

# semi-hard code initially
x = pd.read_csv('../model_selection_summary_results/parsimonious_best_models_by_disease_and_region.csv')

# update disease-region name
x = x.replace('ws_pac', 'ws_pac_acr')

# change threshold from '5' to '05'
x.threshold = x.threshold.replace(5, '05')


# set where model objects will be stored
model_objects_dir = "../model_objects/"

# create and save models
for i in range(4):
    # load dataset
    train_df_filename = str('../compiled_data/survey_data/smote_datasets/') + x.name[i] + str('_smote_train_') + str(x.threshold[i]) + str('.csv')
    train_df = pd.read_csv(train_df_filename)

    # determine response variables based on whether or not column names include "p"
    if 'p' in train_df.columns:
        response = 'p'
    else:
        response = 'Y'
        
    # list covariates
    df_covars = x.iloc[i].Model_variables.split(", ")
    
    # format data for quantile forecst regression
    X_train = train_df[df_covars] 
    Y_train = train_df[response]
    
    # create model
    # n_estimators is number of trees, goes slower as number goes up
    qrf = RandomForestRegressor(n_estimators = 200, random_state = 0, min_samples_split = 10)
    qrf.fit(X_train, Y_train)

    # save models
    fileName = model_objects_dir + x.name[i] + str('.joblib')
    joblib.dump(qrf, fileName)
    
    # plots: not essential, so comment in/out as desired
    # import matplotlib.pyplot as plt
    # from sklearn.inspection import PartialDependenceDisplay
    fig, ax = plt.subplots(figsize=(14, 10))
    ax.set_title(x.name[i])
    pdpfig = PartialDependenceDisplay.from_estimator(qrf, X_train, df_covars, ax = ax)

#     fig2, ax2 = plt.subplots(figsize=(14, 10))
#     ax2.set_title(x.name[i])
#     pdp_plot2 = PartialDependenceDisplay.from_estimator(qrf, X_train, df_covars, ax = ax2, kind = 'both')

    # variable importance plot (https://scikit-learn.org/stable/auto_examples/ensemble/plot_forest_importances.html)
    importances = qrf.feature_importances_
    std = np.std([tree.feature_importances_ for tree in qrf.estimators_], axis=0)

    importances = qrf.feature_importances_
    feature_names = qrf.feature_names_in_
    forest_importances = pd.Series(importances, index=feature_names)

    fig, ax = plt.subplots()
    forest_importances.plot.bar(yerr = std, ax = ax)
    ax.set_title("Feature importances using MDI")
    ax.set_ylabel("Mean decrease in impurity")
    fig.tight_layout()
    fig_filepath = str('../../Figures/Quantile_forests/variable_importance/') + x.name[i] + str('.pdf')
    fig.savefig(fig_filepath) 



