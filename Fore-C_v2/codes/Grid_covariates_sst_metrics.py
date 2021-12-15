# -*- coding: utf-8 -*-
"""
Created on Thu Dec  9 14:06:21 2021

@author: jamie
"""
import wget
import netCDF4 as nc
import pandas as pd
import numpy as np
import datetime as DT


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
firstday = DT.datetime(2021, 11, 7) # start date is 11/8, but using
# index to calculate from here, this will all need to be updated and should
# pull date directly from file

# nowcasts; currently using forecasts, will update in future with satellite observations
# subset to nowcast days
hs_nowcast = hs_vals[nowcast_days,:,:]

# use median value across all forecasts to replace missing data
hs_nowcast_median = np.nanmedian(hs_nowcast)

# fill in NaNs
hs_nowcast = np.ma.filled(hs_nowcast.astype(float), hs_nowcast_median)

# nowcasts
# next is to create the nowcasts, but this code is a placeholder in R,
# so will wait for next iteration of data from Gang in correct format to 
# complete
hs_df = pd.DataFrame()

# forecasts
for j in range(len(forecast_days)):
  # for each ensemble
  for k in range(28):
      x = hs_vals[forecast_days[j], k, :]
      x = np.ma.filled(x.astype(float), np.nanmedian(x))
      
      # create data frame
      tmp_df = pd.DataFrame(hs_id)
      tmp_df['Date'] = firstday + DT.timedelta(days = forecast_days[j])
      tmp_df['Hot_snaps'] = x
      tmp_df['ensemble'] = k + 1
      tmp_df['type'] = 'forecast'
      
      # combine data 
      hs_df = hs_df.append(pd.DataFrame(data = tmp_df), ignore_index=True)

# 90-day SST mean --------------------------------------------------------------
# get id
sst90d_id = sst90d.variables['reef_id'][:]
sst90d_id = pd.DataFrame(sst90d_id , columns = ['ID'])

# dimensions: reef pixel ids x ensemble X days
sst90d_vals = sst90d.variables['daily_90day_mean_sst_prediction'][:]

# reuse first day from above, will update later

# nowcasts
# same as above, create once data is updated

# create new data frame
sst90d_df = pd.DataFrame()

# forecasts
for j in range(len(forecast_days)):
  # for each ensemble
  for k in range(28):
      x = sst90d_vals[forecast_days[j], k, :]
      x = np.ma.filled(x.astype(float), np.nanmedian(x))
      
      # create data frame
      tmp_df = pd.DataFrame(sst90d_id)
      tmp_df['Date'] = firstday + DT.timedelta(days = forecast_days[j])
      tmp_df['SST_90dMean'] = x
      tmp_df['ensemble'] = k + 1
      tmp_df['type'] = 'forecast'
      
      # combine data 
      sst90d_df = sst90d_df.append(pd.DataFrame(data = tmp_df), ignore_index=True)


# combine and save sst metrics -------------------------------------------------
# need to figure out how to join properly

#reef_grid_sst = reef_grid_sst.join(sst90d_df, on = ["ID", "Date", "ensemble", "type"])
reef_grid_sst = pd.merge(hs_df, 
                         sst90d_df, 
                         how = 'left', 
                         on = ['ID',
                               'Date',
                               'ensemble',
                               'type']
                         )

reef_grid_sst.to_csv('../compiled_data/grid_covariate_data/grid_with_sst_metrics.csv',
                     index = False)
