# -*- coding: utf-8 -*-
"""
Format seasonal ocean data 
Last update: 2022-June-23
"""

# load modules
import netCDF4 as nc # v1.5.8
import pandas as pd # v1.4.2
import numpy as np # v1.21.5

# load reef grid
reefsDF = pd.read_csv('./operational/input_data/grid.csv')

# set filepaths
from operational.codes.filepaths import tmp_path, input_path

# load SST data to get matching dates
oc_dates = pd.read_csv(tmp_path + 'grid_with_sst_metrics.csv')
oc_dates = oc_dates.Date.unique()
oc_dates = pd.to_datetime(oc_dates, format = '%Y-%m-%d')
oc_doy = oc_dates.strftime('%j')

# load ocean color data
oc_long_term = nc.Dataset(input_path + 'long_term_metrics_20220531.nc')
oc_pixel_id = nc.Dataset(input_path + 'reef_grid_pixel_id.nc')

# create an array of ids
ids = oc_pixel_id.variables['pixel_id'][:]
ids_loc = np.argwhere(ids != -999.0)

ids_with_values = ids[ids_loc[:,0], ids_loc[:,1]]

# create array of Kd(490) values
tw_kd490_median = oc_long_term.variables['three_week_kd490_median']
tw_kd490_90th = oc_long_term.variables['three_week_kd490_90th']

# loop through all days and extract values for reefs pixel
# this loop takes about 1-4 minutes on standard laptop
oc_metrics = pd.DataFrame()

for i in range(len(oc_doy)):
    # subset to correct day
    median = tw_kd490_median[oc_doy[i], :, :]
    kd90th = tw_kd490_90th[oc_doy[i], :, :]
    # get values for specified pixels
    median_values = median[ids_loc[:,0], ids_loc[:,1]]
    kd90th_values = kd90th[ids_loc[:,0], ids_loc[:,1]]
    # create temporary dataframe
    tmp_df = pd.DataFrame()
    tmp_df['ID'] = ids_with_values
    tmp_df['Date'] = oc_dates[i]
    tmp_df['Three_Week_Kd_Median'] = median_values
    tmp_df['Three_week_kd490_90th'] = kd90th_values
    # add to ocean color dataset
    oc_metrics = pd.concat([oc_metrics, tmp_df])

# add new column for variability
oc_metrics['Three_Week_Kd_Variability'] = oc_metrics['Three_week_kd490_90th'] - oc_metrics['Three_Week_Kd_Median']

# change pixel ID from float to integer
oc_metrics['ID'] = oc_metrics['ID'].astype(int)

# fill NaN with pixel-specific mean (across all dates)
oc_metrics['Three_Week_Kd_Median'] = oc_metrics['Three_Week_Kd_Median'].fillna(oc_metrics.groupby('ID')['Three_Week_Kd_Median'].transform('mean'))
oc_metrics['Three_Week_Kd_Variability'] = oc_metrics['Three_Week_Kd_Variability'].fillna(oc_metrics.groupby('ID')['Three_Week_Kd_Variability'].transform('mean'))

# fill remaining NaN with date-specific mean (across all pixels)
oc_metrics['Three_Week_Kd_Median'] = oc_metrics['Three_Week_Kd_Median'].fillna(oc_metrics.groupby('Date')['Three_Week_Kd_Median'].transform('mean'))
oc_metrics['Three_Week_Kd_Variability'] = oc_metrics['Three_Week_Kd_Variability'].fillna(oc_metrics.groupby('Date')['Three_Week_Kd_Variability'].transform('mean'))

# save
oc_metrics.to_csv(tmp_path + 'grid_with_three_week_oc_metrics.csv', index = False)
    
