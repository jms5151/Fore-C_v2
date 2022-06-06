# -*- coding: utf-8 -*-
"""
Created on Mon Jun  6 13:28:09 2022

@author: jamie
"""

# custom function to join shapefile with datafile of drisk by ID
def create_new_polygon_layers(shpfile, datafile):
    # join data
    joined = shpfile.merge(datafile[['ID', 'drisk']])
    # set geometry
    joined = gpd.GeoDataFrame(joined, geometry = joined.geometry)
    # return file
    return joined