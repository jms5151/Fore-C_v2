# -*- coding: utf-8 -*-
"""
Created on Wed Dec 15 14:27:07 2021

@author: jamie
"""

import netCDF4 as nc
import pandas as pd
import numpy as np
import datetime as DT
import array

import matplotlib.pyplot as plt

# load ocean color data
oc_filepath = '../raw_data/covariate_data/ocean_color/long_term_metrics_20211121.nc'
oc = nc.Dataset(oc_filepath)

# load reef grid
# need to save this as csv file first
load("../compiled_data/spatial_data/grid.RData")

# these need reversing, see fun_extract_oc_data_from_netcdf.R
lats = oc.variables['lat'][:]
lons = oc.variables['lon'][:]

# Long term kd median
ltkdm = oc.variables['long_term_kd490_median'][:]

# trying to figure out wheather matrix needs to be flipped
# don't know how to plot arrays correctly yet, messy code below
from matplotlib.pyplot import imshow
imshow(np.asarray(ltkdm))

# plot to see if matrix needs reversing
df = pd.DataFrame(ltkdm, columns=lons, index=lats)
#df = df[::-1]

loc = list(map(float, df.columns))
fig, ax = plt.subplots()
for row in df.iterrows():
    ax.scatter(row[1], loc, label=row[1].name)
    
plt.imshow(df)
plt.plot(df, 'o')

f_ltkdm = np.flip(df) # or flipud


# fill in NaNs
ltkdm = np.ma.filled(ltkdm.astype(float), 0)

f_ltkdm = np.flip(ltkdm) # or flipud
# plot to see if matrix needs reversing
df = pd.DataFrame(f_ltkdm, columns=lons, index=lats)

plt.imshow(df)
plt.plot(df)


#reef_grid_lt_oc$Long_Term_Kd_Median <- extract_oc_data(variableMatrix = ltkdm,
 #                                                      reefgrid = reef_grid_lt_oc)



