# -*- coding: utf-8 -*-
"""
Created on Thu Dec  9 13:16:31 2021

@author: jamie
"""
import pandas as pd

# set up directory filepaths
forecast_save = "../compiled_data/forecast_outputs/"


def qf_predict(df, regionGBRtrue, covars, family, final_mod, name, fileName2):
    # subset data by region and variables in model
    if regionGBRtrue == True:
        df2 = df.loc[df['Region'].str.contains('gbr')]
    # need to test this with Pacific data
    else:
        col_size = "Median_colony_size_" + family
        df['Median_colony_size'] = df[col_size]
        cv_size = "CV_colony_size_" + family
        df['CV_colony_size'] = df[cv_size]
        df2 = x.loc[~x['Region'].str.contains('gbr')]
    df3 = df2[covars]
    # run model
    pred_Q = pd.DataFrame()
    
    for pred in final_mod.estimators_:
        temp = pd.Series(pred.predict(df3).round(2))
        pred_Q = pd.concat([pred_Q,temp],axis=1)
    
    # calculate quantile values
    RF_actual_pred = pd.DataFrame()
    
    quantiles = [0.05, 0.75, 0.95] # same as used in R, but maybe we want 0.5, 0.75, 0.95?
    
    for q in quantiles:
        s = pred_Q.quantile(q = q, axis = 1)
        RF_actual_pred = pd.concat([RF_actual_pred, s], axis = 1, sort = False)
    
    # rename columns
    RF_actual_pred.rename(columns = {0.05:'Lwr',
                                     0.75:'value',
                                     0.95:'Upr'}, 
                          inplace = True)
    
    id_vars = ["ID", "Latitude", "Longitude", "Region", "Date", "ensemble", "type"]
    
    # concat original data frame of id vars with predictions
    dz_final = pd.concat([df2[id_vars], RF_actual_pred], axis=1) 

    fileName2_full = forecast_save + name + '_' + fileName2
    dz_final.to_csv(fileName2_full, index = False)
