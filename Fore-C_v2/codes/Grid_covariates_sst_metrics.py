# -*- coding: utf-8 -*-
"""
Created on Thu Dec  9 14:06:21 2021

@author: jamie
"""
import wget
import netCDF4 as nc
import pandas as pd
import numpy as np
import datetime


# set crw forecast directory for downloads
crw_dir = "../raw_data/covariate_data/CRW_dz_temp_metrics/crw_temp_forecasts/"

# Download SST metrics from CRW ------------------------------------------------
# Winter Condition
wc_url = "ftp://ftp.star.nesdis.noaa.gov/pub/sod/mecb/gliu/caldwell/20211113/dz-v2_wdw_gbr_reef-id_20211107.nc"
wget.download(wc_url, out = crw_dir + 'WC.nc')

# Hot Snaps
hs_url = "ftp://ftp.star.nesdis.noaa.gov/pub/sod/mecb/gliu/caldwell/20211111/cfsv2_hotsnap_gbr_reef-id_20211106.nc"
wget.download(hs_url, out = crw_dir + 'HS.nc')

# 90 day mean SST
sst90dMean_url = "ftp://ftp.star.nesdis.noaa.gov/pub/sod/mecb/gliu/caldwell/20211114/cfsv2_mean-90d_gbr_reef-id_20211106_new.nc"
wget.download(sst90dMean_url, out = crw_dir + 'SST90dMean.nc')

# load data --------------------------------------------------------------------
# load SST metrics (downloaded above)
wc = nc.Dataset(crw_dir + 'WC.nc')

hs = nc.Dataset(crw_dir + 'HS.nc')

sst90d = nc.Dataset(crw_dir + 'SST90dMean.nc')

# winter condition -------------------------------------------------------------
# this is a single value for each reef pixel
wc_id = wc.variables['reef_id'][:]
wc_id = pd.DataFrame(wc_id, columns = ['ID'])

wc_vals = wc.variables['daily_winter_conditions'][0,:]
wc_vals = pd.DataFrame(wc_vals, columns = ['Winter_condition'])


# fill in NAs with mean values, may need to merge a dataset with ID and region
# to get means by region rather than overall mean!
wc_vals['Winter_condition'] = wc_vals.fillna(wc_vals.mean())

# combine id and winter condition in dataframe
reef_grid_wc = pd.concat([wc_id, wc_vals], axis=1)

# save data
reef_grid_wc.to_csv('../compiled_data/grid_covariate_data/grid_with_wc.csv', index = False)

# SST forecasts ----------------------------------------------------------------
# this code is not streamlined, lots of repeated code between hot snaps and 90 day means
# list dates/index associated with nowcasts and forecasts
nowcast_days = list(range(1, 9, 7)) # the first two weeks, python is inclusive with numbers
forecast_days = list(range(15, 15+(12*7), 7)) # the following 12 weeks

# Hot Snaps --------------------------------------------------------------------
#hs_df <- data.frame()

hs_id = hs.variables['reef_id'][:]
hs_id = pd.DataFrame(hs_id, columns = ['ID'])

# dimensions: reef pixel ids x ensemble X days
hs_vals = hs.variables['daily_hotsnap_prediction'][:]

# This isn't working currently, check with Gang how day id is formatted
# # get day id
# day - based on last day of 7-day initial condition period (Oct 31-6), 239 total
# first day = Nov. 8, 2021
# julianday <- hs$dim$time$vals[1]
# # turn into julian day (first 3 numbers)
# julianday <- as.numeric(substr(julianday, 1, 3))
# # turn into date
# firstday <- as.Date(julianday, origin=as.Date("2021-01-01"))
firstday = datetime.datetime(2021, 11, 7) # start date is 11/8, but using
# index to calculate from here, this will all need to be updated and should
# pull date directly from file

# nowcasts; currently using forecasts, will update in future with satellite observations
# subset to nowcast days
hs_nowcast = hs_vals[nowcast_days,:,:]

# use median value across all forecasts, need to figure out how to do this
# with a masked array
hs_nowcast = np.ma.array(hs_nowcast)
hs_nowcast = hs_nowcast.median(axis = 2)
