# -*- coding: utf-8 -*-
"""
Custom functions to create table of 5 km reef pixels in management zones
Last update: 2022-May-31
"""

def add_drisk(df2, dz):
    # set thresholds by disease-region
    if dz == 'ga':
        nostress_threshold = 5
        watch_threshold = 10
        warning_threshold = 15
        alert1_threshold = 25
    else:
        nostress_threshold = 1
        watch_threshold = 5
        warning_threshold = 10
    # assign risk level
    df2['drisk'] = ''
    # no stress
    nostress_ind = df2.index[(df2['value'] >= 0) & (df2['value'] <= nostress_threshold)].tolist()
    df2.loc[nostress_ind, ('drisk')] = 0
    # watch
    watch_ind = df2.index[(df2['value'] > nostress_threshold) & (df2['value'] <= watch_threshold)].tolist()
    df2.loc[watch_ind, ('drisk')] = 1
    # warning
    warn_ind = df2.index[(df2['value'] > watch_threshold) & (df2['value'] <= warning_threshold)].tolist()
    df2.loc[warn_ind, ('drisk')] = 2
    if dz == 'ga':
        # alert level 1
        alert1_ind = df2.index[(df2['value'] > warning_threshold) & (df2['value'] <= alert1_threshold)].tolist()
        # alert level 2
        alert2_ind = df2.index[(df2['value'] > alert1_threshold)].tolist()
    else:
        # alert level 1
        alert1_ind_gbr = df2.index[(df2['Region'] == 'gbr') & (df2['value'] > warning_threshold) & (df2['value'] <= 20)].tolist()
        alert1_ind_pac = df2.index[(df2['Region'] != 'gbr') & (df2['value'] > warning_threshold) & (df2['value'] <= 15)].tolist()
        alert1_ind = alert1_ind_gbr + alert1_ind_pac
        # alert level 2
        alert2_ind_gbr = df2.index[(df2['Region'] == 'gbr') & (df2['value'] > 20)].tolist()
        alert2_ind_pac = df2.index[(df2['Region'] != 'gbr') & (df2['value'] > 15)].tolist()
        alert2_ind = alert2_ind_gbr + alert2_ind_pac
    # alert level 1
    df2.loc[alert1_ind, ('drisk')] = 3
    # alert level 2
    df2.loc[alert2_ind, ('drisk')] = 4
    # return dataframe
    return df2


def agg_to_manage_zones_forecasts(forecast, management_df, dz):
    # merge datasets
    df = forecast.merge(management_df, left_on = 'ID', right_on = 'PixelID')
    # set ID as PolygonID
    df['ID'] = df['PolygonID']
    # drop columns
    df = df.drop(['PolygonID', 'PixelID', 'Latitude', 'Longitude', 'drisk'], axis = 1) 
    # get quantile values
    df2 = df.groupby(['ID', 'Region', 'Date', 'type']).quantile(0.90).reset_index()
    # assign drisk
    df3 = add_drisk(df2 = df2, dz = dz)
    # return dataframe
    return df3

def agg_to_manage_zones_scenarios(scenario, management_df, dz):
    # merge data
    df = scenario.merge(management_df, left_on = 'ID', right_on = 'PixelID')
    # get median values by group
    df = df.groupby(['PolygonID', 'Region', 'Response', 'Response_level']).median().reset_index()
    # format column names
    df['ID'] = df['PolygonID']
    df2 = df.drop(['PolygonID', 'Latitude', 'Longitude', 'PixelID'], axis = 1)
    # assign drisk
    df3 = add_drisk(df2 = df2, dz = dz)
    # update column names
    df3 = df3.rename(columns = {'predicted': 'value', 'Lwr': 'LwrEstimate', 'Upr': 'UprEstimate', 'value': 'estimate'})
    # return dataframe
    return df3
    
