# -*- coding: utf-8 -*-
"""
Format data for NOAA CRW regional virtual stations
Last update: 2022-July-05
"""

# load module
import os
import pandas as pd # v 1.4.2
import numpy as np
from datetime import date

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

# save by region
regions = reef_forecast['Region'].unique()

for i in regions:
    x = reef_forecast[reef_forecast['Region'] == i]
    x.to_csv(crw_path + 'forec_5km_nowcasts_and_forcasts_' + i + '.csv', index = False)

# time series ------------------------------------------------------------------

def format_ts_predictions(df, diseaseName):
    # determine first day of year
    yr = date.today().year
    cutoff_date = str(yr) + '-01-01'
    # format data
    df = df.rename(columns = {'Date':'Data_date'})
    df = df.loc[df['Data_date'] >= cutoff_date]
    df = df.groupby(['Region', 'Data_date'])[['value', 'Lwr', 'Upr']].quantile(0.90).reset_index()
    df = df.rename(columns = {'value': diseaseName + '75'
                              , 'Lwr': diseaseName + '50'
                              , 'Upr': diseaseName + '90'})
    df['Prediction'] = np.where(df['Data_date'] <= current_nowcast_date, 'Nowcast', 'Forecast')
    return(df)

ga_ts = format_ts_predictions(df = ga_forecast, diseaseName = 'GA')

ws_ts = format_ts_predictions(df = ws_forecast, diseaseName = 'WS')

predictions_ts = pd.merge(left = ga_ts, right = ws_ts)

# save
regions = predictions_ts['Region'].unique()

for i in regions:
  x = predictions_ts[predictions_ts['Region'] == i]
  ts_filepath = crw_path + 'forec_YTD_regional_disease_predictions_' + i + '.csv'
  if os.path.exists(ts_filepath):
    x_old = pd.read_csv(ts_filepath)
    x_old = x_old[x_old['Prediction'] == 'Nowcast']
    x_old = x_old.drop_duplicates() # not sure this is needed
    max_x_old_date = x_old['Data_date'].max()
    x_new = x[x['Data_date'] > max_x_old_date]
    x = pd.concat([x_old, x_new])
  x.to_csv(ts_filepath, index = False)
