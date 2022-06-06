# -*- coding: utf-8 -*-
"""
Created on Wed Jun  1 16:41:41 2022

@author: jamie
"""

import pandas as pd

# load functions
from codes.custom_functions.fun_pixels_to_management_zones import agg_to_manage_zones_scenarios

# set destination directory
scenarios_file_dir = '../compiled_data/scenarios_outputs/'
save_dir = '../compiled_data/map_data/'

# load data
ga_gbr_scenarios = pd.read_csv(scenarios_file_dir + 'ga_gbr_scenarios.csv')
ga_pac_scenarios = pd.read_csv(scenarios_file_dir + 'ga_pac_scenarios.csv')
ws_gbr_scenarios = pd.read_csv(scenarios_file_dir + 'ws_gbr_scenarios.csv')
ws_pac_scenarios = pd.read_csv(scenarios_file_dir + 'ws_pac_scenarios.csv')

# load management information
management_area_poly_pix_ids = pd.read_csv('../uh-noaa-shiny-app/forec_shiny_app_data/Static_data/pixels_in_management_areas_polygons.csv')
gbrmpa_park_zones_poly_pix_ids = pd.read_csv('../uh-noaa-shiny-app/forec_shiny_app_data/Static_data/pixels_in_gbrmpa_park_zones_polygons.csv')

# aggregate to management zones -----------------------------------------------
# GA GBR management zones
x = agg_to_manage_zones_scenarios(scenario = ga_gbr_scenarios, management_df = management_area_poly_pix_ids, dz = 'ga')
x.to_csv(save_dir + 'ga_gbr_polygons_management_zoning.csv', index = False)

# GA Pacific management zones
x = agg_to_manage_zones_scenarios(scenario = ga_pac_scenarios, management_df = management_area_poly_pix_ids, dz = 'ga')
x.to_csv(save_dir + 'ga_pac_polygons_management_zoning.csv', index = False)

# WS GBR management zones
x = agg_to_manage_zones_scenarios(scenario = ws_gbr_scenarios, management_df = management_area_poly_pix_ids, dz = 'ws')
x.to_csv(save_dir + 'ws_gbr_polygons_management_zoning.csv', index = False)

# WS Pacific management zones
x = agg_to_manage_zones_scenarios(scenario = ws_pac_scenarios, management_df = management_area_poly_pix_ids, dz = 'ws')
x.to_csv(save_dir + 'ws_pac_polygons_management_zoning.csv', index = False)

# GA GBR GBRMPA zones
x = agg_to_manage_zones_scenarios(scenario = ga_gbr_scenarios, management_df = gbrmpa_park_zones_poly_pix_ids, dz = 'ga')
x.to_csv(save_dir + 'ga_gbr_polygons_GBRMPA_zoning.csv', index = False)

# WS GBR GBRMPA zones
x = agg_to_manage_zones_scenarios(scenario = ws_gbr_scenarios, management_df = gbrmpa_park_zones_poly_pix_ids, dz = 'ws')
x.to_csv(save_dir + 'ws_gbr_polygons_GBRMPA_zoning.csv', index = False)

