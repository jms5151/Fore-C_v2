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
management_area_poly_pix_ids = pd.read_csv('../uh-noaa-shiny-app/forec_shiny_app_data/Static_data/pixels_in_management_areas_polygons.csv')
gbrmpa_park_zones_poly_pix_ids = pd.read_csv('../uh-noaa-shiny-app/forec_shiny_app_data/Static_data/pixels_in_gbrmpa_park_zones_polygons.csv')

# aggregate -------------------------------------------------------------------
# management zones
ga_management = agg_to_manage_zones_forecasts(
    forecast = ga_forecast
    , management_df = management_area_poly_pix_ids
    , dz = 'ga'
    )

ga_management.to_csv(forecast_file_dir + 'ga_nowcast_aggregated_to_management_zones.csv', index = False)

ws_management = agg_to_manage_zones_forecasts(
    forecast = ws_forecast
    , management_df = management_area_poly_pix_ids
    , dz = 'ws'
    )

ws_management.to_csv(forecast_file_dir + 'ws_nowcast_aggregated_to_management_zones.csv', index = False)

# GBRMPA zones
ga_gbrmpa = agg_to_manage_zones_forecasts(
    forecast = ga_forecast
    , management_df = gbrmpa_park_zones_poly_pix_ids
    , dz = 'ga'
    )

ga_gbrmpa.to_csv(forecast_file_dir + 'ga_gbr_nowcast_aggregated_to_gbrmpa_park_zones.csv', index = False)

ws_gbrmpa = agg_to_manage_zones_forecasts(
    forecast = ws_forecast
    , management_df = gbrmpa_park_zones_poly_pix_ids
    , dz = 'ws'
    )

ws_gbrmpa.to_csv(forecast_file_dir + 'ws_gbr_nowcast_aggregated_to_gbrmpa_park_zones.csv', index = False)

