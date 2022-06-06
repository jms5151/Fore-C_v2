# -*- coding: utf-8 -*-
"""
Created on Thu Jun  2 16:10:39 2022

@author: jamie
"""
import pandas as pd
import geopandas as gpd
import glob

from codes.custom_functions.fun_join_shapefile_with_drisk_data import create_new_polygon_layers

# forecast maps need:
    # 1. nowcast_polygons_5km
    # 2. one_month_forecast_polygons_5km
    # 3. two_month_forecast_polygons_5km
    # 4. three_month_forecast_polygons_5km
    # 5. polygons_GBRMPA_zoning
    # 6. polygons_management_zoning
# scenario maps need:
    # 1. ga_gbr_nowcast_polygons_5km
    # 2. ga_gbr_polygons_GBRMPA_zoning
    # 3. ga_gbr_polygons_management_zoning
    # 4. ws_gbr_nowcast_polygons_5km
    # 5. ws_gbr_polygons_GBRMPA_zoning
    # 6. ws_gbr_polygons_management_zoning
    # 7. ga_pac_nowcast_polygons_5km
    # 8. ga_pac_polygons_management_zoning
    # 9. ws_pac_nowcast_polygons_5km
    # 10. ws_pac_polygons_management_zoning
    
# set directories
shapefile_dir = '../compiled_data/spatial_data/'
map_data_dir = '../compiled_data/map_data/'

# load shapefiles -------------------------------------------------------------
reef_grid_shp = gpd.read_file(shapefile_dir + 'spatial_grid.shp')
management_shp = gpd.read_file(shapefile_dir + 'polygons_management_areas.shp')
gbrmpa_shp = gpd.read_file(shapefile_dir + 'polygons_GBRMPA_park_zoning.shp')

# load model outputs ----------------------------------------------------------

# list files ending with .csv and that don't begin with a dot:
listFiles = glob.glob(map_data_dir + '*.csv')

# loop through each file and create shapefile for leaflet maps
for i in range(len(listFiles)):
    # open file
    df = pd.read_csv(listFiles[i])
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
    if 'scenarios' in listFiles[i]:
            save_path = save_path.replace('compiled_data/map_data', 'uh-noaa-shiny-app/forec_shiny_app_data/Scenarios')
    else:
        save_path = save_path.replace('compiled_data/map_data', 'uh-noaa-shiny-app/forec_shiny_app_data/Forecasts')
    # save file
    x.to_file(save_path)  
