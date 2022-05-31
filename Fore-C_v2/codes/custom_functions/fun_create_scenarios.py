# -*- coding: utf-8 -*-
"""
Created on Tue May 31 09:38:12 2022

@author: jamie
"""

import pandas as pd

# load management information
management_area_poly_pix_ids = pd.read_csv('../uh-noaa-shiny-app/forec_shiny_app_data/Static_data/pixels_in_management_areas_polygons.csv')
gbrmpa_park_zones_poly_pix_ids = pd.read_csv('../uh-noaa-shiny-app/forec_shiny_app_data/Static_data/pixels_in_gbrmpa_park_zones_polygons.csv')


# subset and format data for scenarios
def format_scenario_data(df, regionGBR, nowcast_data, taxa):
    # subset by region
    if regionGBR == True:
        ind = df.index[(df['Region'] == 'gbr')]
    else: 
        ind = df.index[(df['Region'] != 'gbr')]
    df = df.loc[ind]
    # merge nowcast predictions with current predictor variables
    df = df.merge(nowcast_data, on = ['ID', 'Latitude', 'Longitude', 'Region', 'Date', 'type'], how = 'left')
    # format taxa-specific column names to generic columns names
    taxa_names = taxa + '_|_' + taxa
    df.columns = df.columns.str.replace(taxa_names, '', regex = True)
    # return new dataframe
    return df


# get mean values by management area
def agg_for_management_areas(df, management_df):
    # merge datasets
    df2 = df.merge(management_df, left_on = 'ID', right_on = 'PixelID')
    # format ID column name
    df2['ID'] = df2['PolygonID']
    df2 = df2.drop(['PixelID', 'PolygonID'], axis = 1)    
    # get means by management area
    df2 = df2.groupby(['ID']).mean().reset_index()
    return df2


# calculate and save baseline values
def baseline_vals(df, covars, dz_name, regionGBR):
    # baseline values for 5 km pixels
    covars.extend(['ID', 'value'])
    df = df[covars] # keep ID, value, and covars for sliders
    df.loc[:,'value'] = df.loc[:,'value'].round()
    # save 
    fileName1 = '../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/' + dz_name + '_basevals_ID.csv'
    df.to_csv(fileName1, index = False)

    # aggregate baseline values for management areas and save
    df2 = agg_for_management_areas(df = df, management_df = management_area_poly_pix_ids)
    fileName2 = fileName1.replace('ID', 'management')
    df2.to_csv(fileName2, index = False)

    # aggregate baseline values for GBRMPA zoning  
    if regionGBR == True:
        df3 = agg_for_management_areas(df = df, management_df = gbrmpa_park_zones_poly_pix_ids)
        fileName3 = fileName1.replace('ID', 'gbrmpa')
        df3.to_csv(fileName3, index = False)


# function for creating scenarios
def add_scenario_levels(df, scenario_levels, col_name, response_name, scenarios_df):
    for i in scenario_levels:
        df[col_name] = i
        df['Response'] = response_name
        df['Response_level'] = i
        scenarios_df = scenarios_df.append(df)
    return scenarios_df

