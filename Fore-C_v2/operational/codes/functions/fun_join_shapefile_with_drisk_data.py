# -*- coding: utf-8 -*-
"""
Function to create new polygons
Last update: 2022-June-06
"""

# load module
import geopandas as gpd # v 0.6.1

# custom function to join shapefile with datafile of drisk by ID
def create_new_polygon_layers(shpfile, datafile):
    # join data
    joined = shpfile.merge(datafile[['ID', 'drisk']])
    # set geometry
    joined = gpd.GeoDataFrame(joined, geometry = joined.geometry)
    # return file
    return joined