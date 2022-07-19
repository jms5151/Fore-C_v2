# -*- coding: utf-8 -*-
"""
Download and format SST data from satellite observations and CFS
Last update: 2022-June-23
"""

# load modules
import wget # v3.2
import netCDF4 as nc # v1.5.8
import pandas as pd # v1.4.2
import numpy as np # v1.21.5

# load functions
from functions.fun_ftp_download import list_ftp_files
from functions.fun_winter_condition_offset import winter_condition_offset

# set temporary filepath
from filepaths import tmp_path, input_path

# list weekly SST files --------------------------------------

# list directories, named by date
parent_ftp_filepath = 'https://www.star.nesdis.noaa.gov/pub/sod/mecb/crw/data/for_forec/shiny_app/'

files = list_ftp_files(parent_ftp_filepath)

parent_file = [i for i in files if i.startswith('2')][-1]

child_ftp_filepath = parent_ftp_filepath + parent_file
 
files = list_ftp_files(child_ftp_filepath)

# remove extraneous file names
files = [i for i in files if i.startswith('cfs')|i.startswith('dz')|i.startswith('forec')]

# download data ---------------------------------------------
for jj in files:
    # download file
    nc_source_filepath = child_ftp_filepath + jj
    nc_dest_filepath = tmp_path + jj
    wget.download(nc_source_filepath, out = nc_dest_filepath)

# format data ------------------------------------------------

# create empty data frame
sst_metrics = pd.DataFrame()

# open and format data (this should take 1-4 minutes on a standard laptop)
for j in files:
    # open file
    x = nc.Dataset(tmp_path + j)
    # get ids
    ids = x.variables['reef_id'][:]
    ids = pd.DataFrame(ids, columns = ['ID'])
    # get date(s)
    dates = x.variables['data_date'][:]
    dates = pd.DataFrame(dates, columns = ['data_date'])
    # determine metric name
    if 'hotsnap' in j or 'hdw' in j:
        metric_name = 'Hot_snaps'
    elif 'mean-90d' in j: 
         metric_name = 'SST_90dMean'
    else: 
         metric_name = 'Winter_condition'
    # set variable id
    variable_dict = x.variables.keys()
    var_name = list(variable_dict)[2]
    metric_array = x.variables[var_name][:]
    metric_array = np.array(metric_array)
    tmp_df = pd.DataFrame()
    # format forecasts
    if 'cfs' in j:
        for k in range(12): # dates for first 12 weeks of forecasts
            for l in range(28): # ensembles
                # dimensions = dates x ids x values
                tmp_metric = metric_array[k, l, :]
                # make flagged values NaNs
                tmp_metric = np.where(tmp_metric == 253, np.nan, tmp_metric)
                tmp_metric = np.where(tmp_metric == 9999, np.nan, tmp_metric)
                # fill in NaNs with median values
                inds = np.where(np.isnan(tmp_metric))
                tmp_metric[inds] = np.nanmedian(tmp_metric)
                # create dataframe
                cfs_df = ids.copy(deep = True)
                data_date = np.array(dates.iloc[k].repeat(cfs_df.shape[0]))
                cfs_df['Date'] = data_date
                cfs_df['ensemble'] = l + 1
                cfs_df['type'] = 'forecast'
                cfs_df['temp_metric_name'] = metric_name
                cfs_df['value'] = tmp_metric
                tmp_df = pd.concat([tmp_df, cfs_df])

    else:
      tmp_metric = metric_array.copy() 
      # make flagged values NaNs
      tmp_metric = np.where(tmp_metric== 253, np.nan, tmp_metric)
      tmp_metric = np.where(tmp_metric== 9999, np.nan, tmp_metric)
      # fill in NaNs with median values
      inds = np.where(np.isnan(tmp_metric))
      tmp_metric[inds] = np.nanmedian(tmp_metric)
      # create dataframe
      tmp_df = ids.copy(deep = True)
      data_date = np.array(dates.loc[0].repeat(tmp_df.shape[0]))
      tmp_df['Date'] = data_date
      tmp_df['ensemble'] = 0
      tmp_df['type'] = 'nowcast'
      tmp_df['temp_metric_name'] = metric_name
      tmp_df['value'] = tmp_metric[0,]
    # combine data
    sst_metrics = pd.concat([sst_metrics, tmp_df])
    # close nc file
    x.close()
    # print progress
    print('finished', j)

# reshape data ----------------------------------------------

# go from long to wide format
reef_grid_sst = sst_metrics.pivot_table(index = ['ID', 'Date', 'ensemble', 'type']
                                          , columns = 'temp_metric_name'
                                          , values = 'value').reset_index()

# load reef grid
reefsDF = pd.read_csv(input_path + 'grid.csv')

# merge sst data with reef grid
reef_grid_sst = reef_grid_sst.merge(reefsDF, on = 'ID', how = 'left')

# update Winter Condition based on region
winter_condition_offset(df = reef_grid_sst, crw_vs_region_name = 'guam-cnmi', offset_value = 3.73)
winter_condition_offset(df = reef_grid_sst, crw_vs_region_name = 'howland-baker', offset_value = 19.25)
winter_condition_offset(df = reef_grid_sst, crw_vs_region_name = 'johnston', offset_value = 2.85)
winter_condition_offset(df = reef_grid_sst, crw_vs_region_name = 'samoas', offset_value = 4.00)
winter_condition_offset(df = reef_grid_sst, crw_vs_region_name = 'gbr', offset_value = 1.95)
winter_condition_offset(df = reef_grid_sst, crw_vs_region_name = 'hawaii', offset_value = 2.73)
winter_condition_offset(df = reef_grid_sst, crw_vs_region_name = 'jarvis', offset_value = 18.96)
winter_condition_offset(df = reef_grid_sst, crw_vs_region_name = 'palmyra-kingman', offset_value = 7.01)
winter_condition_offset(df = reef_grid_sst, crw_vs_region_name = 'wake', offset_value = 4.01)

# save data --------------------------------------------------
reef_grid_sst.to_csv((tmp_path + 'grid_with_sst_metrics.csv'), index = False)
