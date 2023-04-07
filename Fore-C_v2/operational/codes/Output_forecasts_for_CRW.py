# -*- coding: utf-8 -*-
"""
Format data for NOAA CRW regional virtual stations
Last update: 2023-April-07
"""

# load module
import pandas as pd # v 1.4.2
import numpy as np

# set filepaths
from filepaths import shiny_path, crw_path

# load data
ga_forecast = pd.read_csv(shiny_path + 'Forecasts/ga_forecast.csv')
ws_forecast = pd.read_csv(shiny_path + 'Forecasts/ws_forecast.csv')

# figure out which dates to use
predictions = ga_forecast[['Date', 'type']].drop_duplicates().reset_index()
current_nowcast_date = predictions['Date'].loc[predictions['type'] == 'nowcast'].max()

nowcast_id = predictions.index[predictions['Date'] == current_nowcast_date]

one_month_forecast_date = predictions['Date'][nowcast_id + 4].to_list()[0]
two_month_forecast_date = predictions['Date'][nowcast_id + 8].to_list()[0]
three_month_forecast_date = predictions['Date'][nowcast_id + 12].to_list()[0]

# summarize forecasts ----------------------------------------------------------

# concatenate data
reef_forecast = pd.concat([ga_forecast, ws_forecast])

# format
reef_forecast['Data_date'] = reef_forecast['Date']

# subset to dates of interest
reef_forecast = reef_forecast.loc[(reef_forecast['Date'] == current_nowcast_date)|
                                   (reef_forecast['Date'] == one_month_forecast_date)|
                                   (reef_forecast['Date'] == two_month_forecast_date)|
                                   (reef_forecast['Date'] == three_month_forecast_date)]

# get maximum drisk by unique location and date
reef_forecast = reef_forecast.groupby(['ID', 'Latitude', 'Longitude', 'Region', 'Data_date'])['drisk'].max().reset_index()
# rename
reef_forecast = reef_forecast.rename(columns = {'drisk':'Alert_Level'})

# Add prediction type

# create a list of our conditions
conditions = [
    (reef_forecast['Data_date'] == current_nowcast_date),
    (reef_forecast['Data_date'] == one_month_forecast_date),
    (reef_forecast['Data_date'] == two_month_forecast_date),
    (reef_forecast['Data_date'] == three_month_forecast_date)
    ]

# create a list of the values we want to assign for each condition
values = ['Nowcast', '4 week forecast', '8 week forecast', '12 week forecast']

# create a new column and use np.select to assign values to it using our lists as arguments
reef_forecast['Prediction'] = np.select(conditions, values)

# save
reef_forecast.to_csv(crw_path + 'forec_5km_nowcasts_and_forcasts.csv', index = False)

# time series ------------------------------------------------------------------
def update_vs_region(df):
    # separate NWHI from Hawaii
    nwhi_ind = df.index[(df.Latitude > 22.5) & (df.Latitude < 30) & (df.Longitude > -175.5) & (df.Longitude < -161)].tolist()
    df.loc[nwhi_ind , 'Region'] = 'nwhi'
    # separate guam and cnmi, first change all pixels to guam, then rename cnmi pixels
    guam_cnmi_ind = df.index[df.Region == 'guam_cnmi'].tolist()
    df.loc[guam_cnmi_ind, 'Region'] = 'guam'
    cnmi_ind = df.index[(df.Latitude > 13) & (df.Latitude < 13.5) & (df.Longitude > 144) & (df.Longitude < 145.5)].tolist()
    df.loc[cnmi_ind, 'Region'] = 'cnmi'
    return(df)
        
def format_ts_predictions(df, diseaseName):
    df = df.rename(columns = {'Date':'Data_date'})
    df = df.groupby(['Region', 'Data_date'])[['value', 'Lwr', 'Upr']].quantile(0.90).reset_index()
    df = df.rename(columns = {'value': diseaseName + '75'
                              , 'Lwr': diseaseName + '50'
                              , 'Upr': diseaseName + '90'})
    df['Prediction'] = np.where(df['Data_date'] <= current_nowcast_date, 'Nowcast', 'Forecast')
    return(df)

ga_forecast = update_vs_region(df = ga_forecast)
ga_ts = format_ts_predictions(df = ga_forecast, diseaseName = 'GA')

ws_forecast = update_vs_region(df = ws_forecast)
ws_ts = format_ts_predictions(df = ws_forecast, diseaseName = 'WS')

predictions_ts = pd.merge(left = ga_ts, right = ws_ts)

# save
regions = predictions_ts['Region'].unique()

for i in regions:
  x = predictions_ts[predictions_ts['Region'] == i]
  ts_filepath = crw_path + 'forec_regional_24wk_disease_predictions_' + i + '.csv'
  x.to_csv(ts_filepath, index = False)
