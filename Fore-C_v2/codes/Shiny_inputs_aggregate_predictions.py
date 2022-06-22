# -*- coding: utf-8 -*-
"""
Created on Tue May 31 21:24:14 2022

@author: jamie
"""

import pandas as pd

# load functions
from codes.custom_functions.fun_pixels_to_management_zones import agg_to_manage_zones_forecasts

# set destination directory
forecast_file_dir = '../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/'

# load data
ga_forecast = pd.read_csv(forecast_file_dir + 'ga_forecast.csv')
ws_forecast = pd.read_csv(forecast_file_dir + 'ws_forecast.csv')

# load management information
management_area_poly_pix_ids = pd.read_csv('../compiled_data/spatial_data/pixels_in_management_areas_polygons.csv')
gbrmpa_park_zones_poly_pix_ids = pd.read_csv('../compiled_data/spatial_data/pixels_in_gbrmpa_park_zones_polygons.csv')

# aggregate for weekly time series plots --------------------------------------
# management zones - overall
# GA
ga_management = agg_to_manage_zones_forecasts(
    forecast = ga_forecast
    , management_df = management_area_poly_pix_ids
    , dz = 'ga'
    )

ga_management.to_csv(forecast_file_dir + 'ga_nowcast_aggregated_to_management_zones.csv', index = False)

# WS
ws_management = agg_to_manage_zones_forecasts(
    forecast = ws_forecast
    , management_df = management_area_poly_pix_ids
    , dz = 'ws'
    )

ws_management.to_csv(forecast_file_dir + 'ws_nowcast_aggregated_to_management_zones.csv', index = False)

# management zones - split by disease and region
# GA Pacific
ga_pac_forecast = ga_forecast[ga_forecast['Region'] != 'gbr']

ga_pac_management = agg_to_manage_zones_forecasts(
    forecast = ga_pac_forecast
    , management_df = management_area_poly_pix_ids
    , dz = 'ga'
    )

ga_pac_management.to_csv(forecast_file_dir + 'ga_pac_nowcast_aggregated_to_management_zones.csv', index = False)

# GA GBR
ga_gbr_forecast = ga_forecast[ga_forecast['Region'] == 'gbr']

ga_gbr_management = agg_to_manage_zones_forecasts(
    forecast = ga_gbr_forecast
    , management_df = management_area_poly_pix_ids
    , dz = 'ga'
    )

ga_gbr_management.to_csv(forecast_file_dir + 'ga_gbr_nowcast_aggregated_to_management_zones.csv', index = False)

# WS Pacific
ws_pac_forecast = ws_forecast[ws_forecast['Region'] != 'gbr']

ws_pac_management = agg_to_manage_zones_forecasts(
    forecast = ws_pac_forecast
    , management_df = management_area_poly_pix_ids
    , dz = 'ws'
    )

ws_pac_management.to_csv(forecast_file_dir + 'ws_pac_nowcast_aggregated_to_management_zones.csv', index = False)

# WS GBR
ws_gbr_forecast = ws_forecast[ws_forecast['Region'] == 'gbr']

ws_gbr_management = agg_to_manage_zones_forecasts(
    forecast = ws_gbr_forecast
    , management_df = management_area_poly_pix_ids
    , dz = 'ws'
    )

ws_gbr_management.to_csv(forecast_file_dir + 'ws_gbr_nowcast_aggregated_to_management_zones.csv', index = False)

# GBRMPA zones
# GA
ga_gbrmpa = agg_to_manage_zones_forecasts(
    forecast = ga_forecast
    , management_df = gbrmpa_park_zones_poly_pix_ids
    , dz = 'ga'
    )

ga_gbrmpa.to_csv(forecast_file_dir + 'ga_gbr_nowcast_aggregated_to_gbrmpa_park_zones.csv', index = False)

# WS
ws_gbrmpa = agg_to_manage_zones_forecasts(
    forecast = ws_forecast
    , management_df = gbrmpa_park_zones_poly_pix_ids
    , dz = 'ws'
    )

ws_gbrmpa.to_csv(forecast_file_dir + 'ws_gbr_nowcast_aggregated_to_gbrmpa_park_zones.csv', index = False)

# format and combine for polygons ---------------------------------------------
save_dir = '../compiled_data/map_data/'

def max_drisk_df(ga_df, ws_df):
    # format disease data
    ga_df['GA'] = ga_df['drisk']
    ws_df['WS'] = ws_df['drisk']
    # combine
    reef_df = ga_df[['ID', 'Region', 'Date', 'type', 'GA']].merge(ws_df[['ID', 'Date', 'Region', 'type', 'WS']])
    reef_df['drisk'] = reef_df[['GA', 'WS']].max(axis = 1)
    # return new dataframe
    return reef_df

# 5 km data -------------------------------------------------------------------
reef_forecast = max_drisk_df(ga_df = ga_forecast, ws_df = ws_forecast)

# determine nowcast and forecast dates
prediction_dates = reef_forecast['Date'].unique().tolist()
nowcast_date = reef_forecast['Date'].loc[reef_forecast['type'] == 'nowcast'].unique().max()
nowcast_id = prediction_dates.index(nowcast_date)

one_month_forecast_date = prediction_dates[nowcast_id + 4]
two_month_forecast_date = prediction_dates[nowcast_id + 8]
three_month_forecast_date = prediction_dates[nowcast_id + 12]

# subset nowcast data for 5 km map
reef_nowcast_5km = reef_forecast.loc[reef_forecast['Date'] == nowcast_date, ['ID', 'drisk']]
reef_nowcast_5km.to_csv(save_dir + 'nowcast_polygons_5km.csv', index = False)

# subset one month forecast data for 5 km map
reef_1Mforecast_5km = reef_forecast.loc[reef_forecast['Date'] == one_month_forecast_date, ['ID', 'drisk']]
reef_1Mforecast_5km.to_csv(save_dir + 'one_month_forecast_polygons_5km.csv', index = False)

# subset two month forecast data for 5 km map
reef_2Mforecast_5km = reef_forecast.loc[reef_forecast['Date'] == two_month_forecast_date, ['ID', 'drisk']]
reef_2Mforecast_5km.to_csv(save_dir + 'two_month_forecast_polygons_5km.csv', index = False)

# subset three month forecast data for 5 km map
reef_3Mforecast_5km = reef_forecast.loc[reef_forecast['Date'] == three_month_forecast_date, ['ID', 'drisk']]
reef_3Mforecast_5km.to_csv(save_dir + 'three_month_forecast_polygons_5km.csv', index = False)

# separate by disease for scenarios page - 5 km ------------------------------
# GA GBR
ga_gbr_5km = ga_forecast[ga_forecast['Region'] == 'gbr']
ga_gbr_5km = ga_gbr_5km[['ID', 'drisk']]
ga_gbr_5km.to_csv(save_dir + 'ga_gbr_nowcast_polygons_5km.csv', index = False)

# GA Pacific
ga_pac_5km = ga_forecast[ga_forecast['Region'] != 'gbr']
ga_pac_5km = ga_pac_5km[['ID', 'drisk']]
ga_pac_5km.to_csv(save_dir + 'ga_pac_nowcast_polygons_5km.csv', index = False)

# WS GBR
ws_gbr_5km = ws_forecast[ws_forecast['Region'] == 'gbr']
ws_gbr_5km = ws_gbr_5km[['ID', 'drisk']]
ws_gbr_5km.to_csv(save_dir + 'ws_gbr_nowcast_polygons_5km.csv', index = False)

# WS Pacific
ws_pac_5km = ws_forecast[ws_forecast['Region'] != 'gbr']
ws_pac_5km = ws_pac_5km[['ID', 'drisk']]
ws_pac_5km.to_csv(save_dir + 'ws_pac_nowcast_polygons_5km.csv', index = False)

# Management scale data -------------------------------------------------------
management_nowcast = max_drisk_df(ga_df = ga_management, ws_df = ws_management)

# subset to nowcast date
management_nowcast = management_nowcast.loc[management_nowcast['Date'] == nowcast_date, ['ID', 'drisk']]
management_nowcast.to_csv(save_dir + 'polygons_management_zoning.csv', index = False)

# GA GBR
ga_gbr_management_nowcast = ga_gbr_management.loc[ga_gbr_management['Date'] == nowcast_date, ['ID', 'drisk']]
ga_gbr_management.to_csv(save_dir + 'ga_gbr_polygons_management_zoning.csv', index = False)

# GA Pacific
ga_pac_management_nowcast = ga_pac_management.loc[ga_pac_management['Date'] == nowcast_date, ['ID', 'drisk']]
ga_pac_management.to_csv(save_dir + 'ga_pac_polygons_management_zoning.csv', index = False)

# WS GBR
ws_gbr_management_nowcast = ws_gbr_management.loc[ws_gbr_management['Date'] == nowcast_date, ['ID', 'drisk']]
ws_gbr_management.to_csv(save_dir + 'ws_gbr_polygons_management_zoning.csv', index = False)

# WS Pacific
ws_pac_management_nowcast = ws_pac_management.loc[ws_pac_management['Date'] == nowcast_date, ['ID', 'drisk']]
ws_pac_management.to_csv(save_dir + 'ws_pac_polygons_management_zoning.csv', index = False)

# GBRMPA zone data ------------------------------------------------------------
gbrmpa_nowcast = max_drisk_df(ga_df = ga_gbrmpa, ws_df = ga_gbrmpa)

# subset to nowcast date
gbrmpa_nowcast = gbrmpa_nowcast.loc[gbrmpa_nowcast['Date'] == nowcast_date, ['ID', 'drisk']]
gbrmpa_nowcast.to_csv(save_dir + 'polygons_GBRMPA_zoning.csv', index = False)

# GA GBR
ga_gbrmpa_nowcast = ga_gbrmpa.loc[ga_gbrmpa['Date'] == nowcast_date, ['ID', 'drisk']]
ga_gbrmpa_nowcast.to_csv(save_dir + 'ga_gbr_polygons_GBRMPA_zoning.csv', index = False)

# WS GBR
ws_gbrmpa_nowcast = ws_gbrmpa.loc[ws_gbrmpa['Date'] == nowcast_date, ['ID', 'drisk']]
ws_gbrmpa_nowcast.to_csv(save_dir + 'ws_gbr_polygons_GBRMPA_zoning.csv', index = False)
