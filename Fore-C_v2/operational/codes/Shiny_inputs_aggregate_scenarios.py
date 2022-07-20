# -*- coding: utf-8 -*-
"""
Aggregate scenario predictions to different regional management zones
Last update: 2022-July-20
"""

# load module
import pandas as pd # v 1.4.2

# set filepaths
from filepaths import input_path, shiny_path

# destination directory
scenarios_file_dir = shiny_path + 'Scenarios/'

# load functions
from functions.fun_pixels_to_management_zones import agg_to_manage_zones_scenarios

# load data
ga_gbr_scenarios = pd.read_csv(scenarios_file_dir + 'ga_gbr_scenarios.csv')
ga_pac_scenarios = pd.read_csv(scenarios_file_dir + 'ga_pac_scenarios.csv')
ws_gbr_scenarios = pd.read_csv(scenarios_file_dir + 'ws_gbr_scenarios.csv')
ws_pac_scenarios = pd.read_csv(scenarios_file_dir + 'ws_pac_scenarios.csv')

# load management information
management_area_poly_pix_ids = pd.read_csv(input_path + 'pixels_in_management_areas_polygons.csv')
gbrmpa_park_zones_poly_pix_ids = pd.read_csv(input_path + 'pixels_in_gbrmpa_park_zones_polygons.csv')

# aggregate to management zones -----------------------------------------------

# GA GBR management zones
x = agg_to_manage_zones_scenarios(scenario = ga_gbr_scenarios, management_df = management_area_poly_pix_ids, dz = 'ga')
x.to_csv(scenarios_file_dir + 'ga_gbr_scenarios_aggregated_to_management_zones.csv', index = False)

# GA Pacific management zones
x = agg_to_manage_zones_scenarios(scenario = ga_pac_scenarios, management_df = management_area_poly_pix_ids, dz = 'ga')
x.to_csv(scenarios_file_dir + 'ga_pac_scenarios_aggregated_to_management_zones.csv', index = False)

# WS GBR management zones
x = agg_to_manage_zones_scenarios(scenario = ws_gbr_scenarios, management_df = management_area_poly_pix_ids, dz = 'ws')
x.to_csv(scenarios_file_dir + 'ws_gbr_scenarios_aggregated_to_management_zones.csv', index = False)

# WS Pacific management zones
x = agg_to_manage_zones_scenarios(scenario = ws_pac_scenarios, management_df = management_area_poly_pix_ids, dz = 'ws')
x.to_csv(scenarios_file_dir + 'ws_pac_scenarios_aggregated_to_management_zones.csv', index = False)

# GA GBR GBRMPA zones
x = agg_to_manage_zones_scenarios(scenario = ga_gbr_scenarios, management_df = gbrmpa_park_zones_poly_pix_ids, dz = 'ga')
x.to_csv(scenarios_file_dir + 'ga_gbr_scenarios_aggregated_to_gbrmpa_park_zones.csv', index = False)

# WS GBR GBRMPA zones
x = agg_to_manage_zones_scenarios(scenario = ws_gbr_scenarios, management_df = gbrmpa_park_zones_poly_pix_ids, dz = 'ws')
x.to_csv(scenarios_file_dir + 'ws_gbr_scenarios_aggregated_to_gbrmpa_park_zones.csv', index = False)

