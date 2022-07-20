# -*- coding: utf-8 -*-
"""
Update polygons for Shiny app maps
Last update: 2022-July-20

forecast maps need:
    1. nowcast_polygons_5km
    2. one_month_forecast_polygons_5km
    3. two_month_forecast_polygons_5km
    4. three_month_forecast_polygons_5km
    5. polygons_GBRMPA_zoning
    6. polygons_management_zoning
scenario maps need:
    1. ga_gbr_nowcast_polygons_5km
    2. ga_gbr_polygons_GBRMPA_zoning
    3. ga_gbr_polygons_management_zoning
    4. ws_gbr_nowcast_polygons_5km
    5. ws_gbr_polygons_GBRMPA_zoning
    6. ws_gbr_polygons_management_zoning
    7. ga_pac_nowcast_polygons_5km
    8. ga_pac_polygons_management_zoning
    9. ws_pac_nowcast_polygons_5km
    10. ws_pac_polygons_management_zoning
"""

# load modules
import os
import pandas as pd # v1.4.2
import geopandas as gpd # v 0.6.1

# set filepaths
from filepaths import input_path, tmp_path, shiny_path
map_data_dir = tmp_path + 'map_data/'
shiny_forecast_dir = shiny_path + 'Forecasts'

# load function
from functions.fun_join_shapefile_with_drisk_data import create_new_polygon_layers

# load shapefiles -------------------------------------------------------------
reef_grid_shp = gpd.read_file(input_path + 'spatial_grid.shp')
management_shp = gpd.read_file(input_path + 'polygons_management_areas.shp')
gbrmpa_shp = gpd.read_file(input_path + 'polygons_GBRMPA_park_zoning.shp')

# load model outputs ----------------------------------------------------------

# list files
listFiles = os.listdir(map_data_dir)

# loop through each file and create shapefile for leaflet maps
for i in range(len(listFiles)):
    # open file
    df = pd.read_csv(map_data_dir + listFiles[i])
    # set shapefile based on level of df
    if '5km' in listFiles[i]:
        shpName = reef_grid_shp
    elif 'management' in listFiles[i]:
        shpName = management_shp
    else: 
        shpName = gbrmpa_shp
    # join model outputs to shapefiles
    x = create_new_polygon_layers(shpfile = shpName, datafile = df)
    # create filepath to save polygon layer
    save_path = listFiles[i].replace('csv', 'shp')
    save_path = shiny_forecast_dir + '/' + save_path
    # save file
    x.to_file(save_path)  
