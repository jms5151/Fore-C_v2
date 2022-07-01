# -*- coding: utf-8 -*-
"""
Custom functions for predicting with quantile forecasts
Last update: 2022-June-23
"""

# load modules
import os
import pandas as pd # v1.4.2

def qf_new_data_subset(df, regionGBRtrue, family, final_mod):
    # subset data by region and variables in model
    if regionGBRtrue == True:
        coral_cov = 'Coral_cover_' + family
        df['Coral_cover'] = df[coral_cov]
        df = df[df['Region'] == 'gbr']
    else:
        col_size = 'Median_colony_size_' + family
        df['Median_colony_size'] = df[col_size]
        cv_size = 'CV_colony_size_' + family
        df['CV_colony_size'] = df[cv_size]
        df = df[df['Region'] != 'gbr']
    id_vars = ["ID", "Latitude", "Longitude", "Region", "Date", "ensemble", "type"]
    list_covars = final_mod.feature_names_in_.tolist()
    cols_to_keep = id_vars + list_covars
    df = df[cols_to_keep]
    df = df.dropna()
    return df

def qf_predict(df, final_mod, id_vars):
    df2 = df.copy(deep = True)
    list_covars = final_mod.feature_names_in_.tolist()
    df2 = df2[list_covars]
    
    # run model
    pred_Q = pd.DataFrame()
    
    for pred in final_mod.estimators_:
        temp = pd.Series(pred.predict(df2.values).round(2))
        pred_Q = pd.concat([pred_Q, temp], axis = 1)
    
    # calculate quantile values
    RF_actual_pred = pd.DataFrame()
    
    quantiles = [0.50, 0.75, 0.90] 
    
    for q in quantiles:
        s = pred_Q.quantile(q = q, axis = 1)
        RF_actual_pred = pd.concat([RF_actual_pred, s], axis = 1, sort = False)
    
    # rename columns
    RF_actual_pred.rename(columns = {0.50:'Lwr',
                                     0.75:'value',
                                     0.90:'Upr'}, 
                          inplace = True)
    
    # concat original data frame of id vars with predictions
    dz_final = pd.concat([df[id_vars].reset_index(drop = True), RF_actual_pred.reset_index(drop = True)], axis = 1) 
    
    return dz_final


def qf_predict_new(df, regionGBRtrue, family, final_mod, id_vars):
    x = qf_new_data_subset(df = df, regionGBRtrue = regionGBRtrue, family = family, final_mod = final_mod)
    x2 = qf_predict(df = x, final_mod = final_mod, id_vars = id_vars)
    return x2    

def update_forecasts(df_filepath, new_df):
    # if data already exist, load file
    if os.path.exists(df_filepath):
        old_df = pd.read_csv(df_filepath)
        # if there are 12 dates of NRT predictions, remove earliest
        nowcast_dates = old_df.Date[(old_df['type'] == 'nowcast')].unique()
        if len(nowcast_dates) == 12:
            oldest_prediction_date = nowcast_dates.min()
            old_df.drop(old_df[old_df['Date'] == oldest_prediction_date].index, inplace = True)
        # remove forecasts
        old_df.drop(old_df[old_df['type'] == 'forecast'].index, inplace = True)
        # add updated forecasts
        updated_forecast = pd.concat([old_df,new_df])
    else:
        updated_forecast = new_df
    # Ensure there are no duplicates 
    updated_forecast = updated_forecast.drop_duplicates()
    return updated_forecast

def combine_regional_forecasts(gbr_df, pac_df):
    # combine, group, and summarise
    forecast = pd.concat([gbr_df, pac_df]
        ).drop(
            ['ensemble'], axis=1
            ).groupby(
                ['ID', 'Latitude', 'Longitude', 'Region', 'Date', 'type']
                ).quantile(
                    q = 0.90
                    ).reset_index()
    
    # format predictions
    gbr_ind = forecast.index[forecast['Region'] == 'gbr'].tolist()
    pac_ind = forecast.index[forecast['Region'] != 'gbr'].tolist()
    
    # Make values for Pacific model a percent
    forecast.loc[pac_ind, ('value', 'Lwr', 'Upr')] = forecast.loc[pac_ind, ('value', 'Lwr', 'Upr')].multiply(100).round()
    
    # Make values for GBR model integers
    forecast.loc[gbr_ind, ('value', 'Lwr', 'Upr')] = forecast.loc[gbr_ind, ('value', 'Lwr', 'Upr')].round()
    
    # return df
    return forecast


# scenarios predictions
def qf_scenarios_data_subset(df, regionGBRtrue, family, final_mod):
    # add family names back in
    if regionGBRtrue == True:
        coral_cov = 'Coral_cover_' + family
        df[coral_cov] = df['Coral_cover']
        df = df[df['Region'] == 'gbr']
    else:
        coral_cov = family + '_mean_cover'
        df[coral_cov] = df['mean_cover']
        col_size = 'Median_colony_size_' + family
        df[col_size] = df['Median_colony_size']
        df = df[df['Region'] != 'gbr']
    df['predicted'] = df['value']
    id_vars = ["ID", "Latitude", "Longitude", "Region", "Date", "predicted", "Response", "Response_level"]
    list_covars = final_mod.feature_names_in_.tolist()
    cols_to_keep = id_vars + list_covars
    df = df[cols_to_keep]
    df = df.dropna()
    return df

def qf_predict_scenarios(df, regionGBRtrue, family, final_mod, id_vars):
    x = qf_scenarios_data_subset(df = df, regionGBRtrue = regionGBRtrue, family = family, final_mod = final_mod)
    x2 = qf_predict(df = x, final_mod = final_mod, id_vars = id_vars)
    if regionGBRtrue == True:
        x2['disease_risk_change'] = (x2['value'] - x2['predicted']).round()
    else:
        x2['disease_risk_change'] = (x2['value'].multiply(100) - x2['predicted']).round()
        risk_ind = x2.index[x2['disease_risk_change'] < -100].tolist()
        x2.loc[risk_ind, 'disease_risk_change'] = -100
    return x2   
    
    
    