# Model predictions for withheld validation data for nowcasts

# load library
library(tidyverse)
library(quantregForest)
library(ncdf4)
library(httr)

# hard code directory and file loading -----------------------------------------

# load data to create V3 predictions
smote_dir <- '../compiled_data/survey_data/smote_datasets/'

GA_GBR_filepath <- paste0(smote_dir, 'ga_gbr_smote_test_15.csv')
GA_Pacific_filepath <- paste0(smote_dir, 'ga_pac_smote_test_20.csv')
WS_GBR_filepath <- paste0(smote_dir, 'ws_gbr_smote_test_10.csv')
WS_Pacific_filepath <- paste0(smote_dir, 'ws_pac_acr_smote_test_10.csv')

ga_gbr_df <- read.csv(GA_GBR_filepath)
ga_pac_df <- read.csv(GA_Pacific_filepath)
ws_gbr_df <- read.csv(WS_GBR_filepath)
ws_pac_df <- read.csv(WS_Pacific_filepath)

# load data with CRW unique id to create V3 forecast predictions
validation_filepath <- '../compiled_data/survey_data/validation_data/forec_validation_df_2022-06-16_crw_addition_v20220622.csv'
crw_validation_df <- read.csv(validation_filepath)

# load final model objects
source('./codes/Final_covariates_by_disease_and_region.R')

# -----------------------------------------------------------------------------#
# NOWCAST PREDICTIONS ---------------------------------------------------------#
# -----------------------------------------------------------------------------#

# load and format V2 predictions
basePath_id <- '../compiled_data/survey_data/validation_data/forec_ws_REGION_validation_df_2022-06-16_withID.csv'
basePath_pred <- '../compiled_data/survey_data/validation_data/forec_ws_REGION_validation_df_2022-06-16_withID-SFHoutput.csv'

formatV2data <- function(regionName){
  if(regionName == 'Pacific'){
    v2_filepath_id <- gsub('REGION', 'pacific', basePath_id) 
    v2_filepath_pred <- gsub('REGION', 'pacific', basePath_pred) 
    validation_df <- ws_pac_df
    validation_df$Observed <- validation_df$p
  } else {
    v2_filepath_id <- gsub('REGION', 'gbr', basePath_id) 
    v2_filepath_pred <- gsub('REGION', 'gbr', basePath_pred) 
    validation_df <- ws_gbr_df
    validation_df$Observed <- validation_df$Y
  }
  # read in v2 data
  v2_id <- read.csv(v2_filepath_id)
  v2_df <- read.csv(v2_filepath_pred)
  # add id
  validation_df$ScottID <- v2_id$ScottID
  # combine
  v2_df2 <- v2_df[, c('ScottID', 'riskSyn')] %>% #, 'riskData' alternative risk measure
    left_join(validation_df[, c('ScottID', 'Observed')]) %>%
    drop_na() %>%
    mutate(
      Version = 'V2'
      , Region = regionName
      , Disease = 'White syndromes'
      , V3_Q50 = NA
      , V3_Q90 = NA
    ) %>%
    rename(
      Predicted = riskSyn #riskData
    ) %>%
    select(Version, Region, Disease, Observed, V3_Q50, Predicted, V3_Q90)
  # make negative predictions = 0
  v2_df2$Predicted[v2_df2$Predicted < 0] <- 0
  # return dataframe
  v2_df2
}

v2_ws_pac <- formatV2data(regionName = 'Pacific')
v2_ws_gbr <- formatV2data(regionName = 'GBR')

# save
save(v2_ws_pac, file = '../compiled_data/survey_data/validation_data/v2_ws_pac.RData')
save(v2_ws_gbr, file = '../compiled_data/survey_data/validation_data/v2_ws_gbr.RData')

# function to predict V3 model risk on new data --------------------------------
predictNew <- function(final_model, new_df, regionName, diseaseName){
  
  # predict on new dataset
  xpredict <- predict(
    final_model
    , what = c(0.50, 0.75, 0.90)
    , newdata = new_df
    )
  
  # concatenate "new dataset" response with predicted outcome (with uncertainty) 
  observed_response_variable <- colnames(new_df)[grep('^Y$|^p$', colnames(new_df))]
  
  x2 <- cbind(
    'Version' = 'V3'
    , 'Region' = regionName
    , 'Disease' = diseaseName
    , 'Observed' = new_df[, observed_response_variable]
    , 'V3_Q50' = xpredict[,1]
    , 'Predicted' = xpredict[,2]
    , 'V3_Q90' = xpredict[,3]
    )
  
  # return output
  as.data.frame(x2)
}

colNames_to_numeric <- c('Observed', 'V3_Q50', 'Predicted', 'V3_Q90')

# White syndromes - Pacific ----------------------------------------------------

# V3 prediction
v3_ws_pac <- predictNew(
  final_model = WS_Pacific_Model
  , new_df = ws_pac_df
  , regionName = 'Pacific'
  , diseaseName = 'White syndromes'
  )

# format
v3_ws_pac[, colNames_to_numeric] <- lapply(
  v3_ws_pac[, colNames_to_numeric]
  , function(x) as.numeric(x)
)

# save
save(v3_ws_pac, file = '../compiled_data/survey_data/validation_data/v3_ws_pac.RData')

# White syndromes - GBR --------------------------------------------------------

# V3 prediction
v3_ws_gbr <- predictNew(
  final_model = WS_GBR_Model
  , new_df = ws_gbr_df
  , regionName = 'GBR'
  , diseaseName = 'White syndromes'
)

# format
v3_ws_gbr[, colNames_to_numeric] <- lapply(
  v3_ws_gbr[, colNames_to_numeric]
  , function(x) as.numeric(x)
)

# save
save(v3_ws_gbr, file = '../compiled_data/survey_data/validation_data/v3_ws_gbr.RData')

# Growth anomalies - Pacific ----------------------------------------------------

# V3 prediction
V3_ga_pac <- predictNew(
  final_model = GA_Pacific_Model
  , new_df = ga_pac_df
  , regionName = 'Pacific'
  , diseaseName = 'Growth anomalies'
)

# format
V3_ga_pac[, colNames_to_numeric] <- lapply(
  V3_ga_pac[, colNames_to_numeric]
  , function(x) as.numeric(x)
)

# save
save(v3_ga_pac, file = '../compiled_data/survey_data/validation_data/v3_ga_pac.RData')

# Growth anomalies - GBR ----------------------------------------------------

# V3 prediction
v3_ga_gbr <- predictNew(
  final_model = GA_GBR_Model
  , new_df = ga_gbr_df
  , regionName = 'GBR'
  , diseaseName = 'Growth anomalies'
)

# format
v3_ga_gbr[, colNames_to_numeric] <- lapply(
  v3_ga_gbr[, colNames_to_numeric]
  , function(x) as.numeric(x)
)

# save
save(v3_ga_gbr, file = '../compiled_data/survey_data/validation_data/v3_ga_gbr.RData')

# -----------------------------------------------------------------------------#
# FORECAST PREDICTIONS --------------------------------------------------------#
# -----------------------------------------------------------------------------#
# get SST forecasts for lead weeks 1 - 12 ------------
# source custom function 
source("./codes/custom_functions/fun_ftp_download.R")

# list files to download
forecast_filepath <- 'https://www.star.nesdis.noaa.gov/pub/sod/mecb/gliu/caldwell/validation/'
files <- list_ftp_files(ftp_path = forecast_filepath)

# format files
files <- files[grep('.nc', files)]
files <- gsub('.*href=\"|nc.*', '', files)
files <- files[!grepl('recs01251', files)] # remove an erroneous file

# create and save empty data frame
sst_metrics <- data.frame()

# download and concatenate data
for(i in 1:length(files)){
  ftp_path_tmp <- paste0(forecast_filepath, files[i], 'nc')
  res <- GET(ftp_path_tmp, write_disk(basename(ftp_path_tmp), overwrite = TRUE))
  x <- nc_open(res$request$output$path)
  # get coordinates
  lats <- ncvar_get(x, varid = "record_latitude")
  lons <- ncvar_get(x, varid = "record_longitude")
  # get dates
  dates <- ncvar_get(x, varid = "record_date")
  # get ids
  ids  <- ncvar_get(x, varid = "unique_id")
  # determine metric name
  if(grepl('hdw', files[i]) == TRUE){
    metric_name <- 'Hot_snaps'
  } else if(grepl('mean-90d', files[i]) == TRUE){
    metric_name <- 'SST_90dMean'
  } else {
    metric_name <- 'Winter_condition'
  }
  metric_array <- ncvar_get(x, varid = names(x$var)[10])
  tmp_df <- data.frame()
  for(k in 1:12){ # lead time
    for(l in 1:28){ # ensembles
      tmp_metric <- metric_array[k, l, ]
      # make flagged values NAs
      tmp_metric[tmp_metric == 253|tmp_metric == 9999] <- NA
      # fill in NAs with median values
      tmp_metric[is.na(tmp_metric)] <- median(tmp_metric, na.rm = T)
      # create dataframe
      cfs_df <- data.frame("UniqueID" = ids
                           , "CRW_Latitude" = lats
                           , "CRW_Longitude" = lons
                           , "CRW_date" = dates[k]
                           , "Lead_time" = k
                           , "ensemble" = l
                           , "temp_metric_name" = metric_name
                           , "value" = tmp_metric
                           )
      tmp_df <- rbind(tmp_df, cfs_df)
    }
  }
  # combine data
  sst_metrics <- rbind(sst_metrics, tmp_df)
  nc_close(x)
  file.remove(paste0(files[i], 'nc'))
  cat("finished ", files[i], '\n')
}

# temporarily save whole file in case R crashes
save_path <- '../compiled_data/survey_data/validation_data/sst_cfs_forecasts_validation.RData'
save(sst_metrics, file = save_path)

# format from long to wide 
sst_wide <- sst_metrics %>% 
  spread(key = temp_metric_name, value = value)

# overwrite above file
save(sst_wide, file = save_path)

# add CRW unique id to other predictor data (loaded at top of code) 
sst_wide_with_id <- sst_wide %>%
  select(-c(CRW_Latitude, CRW_Longitude, CRW_date)) %>%
  left_join(crw_validation_df[, c('Latitude', 'Longitude', 'Date', 'UniqueID')], by = 'UniqueID') %>%
  mutate(Date = as.Date(Date, '%Y-%m-%d'))

# function to combine forecast/nowcast predictor data
source("./codes/custom_functions/fun_split_df_by_n.R")

format_forecast_data <- function(df){
  
  # format date
  df$Date <- paste(df$Year, df$Month, df$Day, sep = '-')  
  df$Date <- as.Date(df$Date, '%Y-%m-%d')
  
  # remove sst metric columns from nowcast df to replace with forecasts  
  sst_cols_to_remove <- colnames(df)[grep('Hot_snaps|Winter_condition|SST_90dMean', colnames(df))]
  
  df_forecast <- df %>% 
    select(-all_of(sst_cols_to_remove)) %>%
    inner_join(sst_wide_with_id)
  
  # add lead time and ensemble for nowcast
  df$Lead_time <- 0
  df$ensemble <- 0

  # combine dataframes
  dfNew <- bind_rows(df, df_forecast)
  
  # split dataframe into list of smaller dataframes for better processing speed
  dfList <- split_df_by_n(nrowSize = 100000, df = dfNew)
  
  # return list
  return(dfList)
  
}

# update predictor data for forecasts with different lead times and ensembles
ga_gbr_forecast_df <- format_forecast_data(df = ga_gbr_df)
ga_pac_forecast_df <- format_forecast_data(df = ga_pac_df)
ws_gbr_forecast_df <- format_forecast_data(df = ws_gbr_df)
ws_pac_forecast_df <- format_forecast_data(df = ws_pac_df)

# updated function to predict V3 model risk on new data with different lead times
predictNewCFS <- function(final_model, new_df, regionName, diseaseName){
  
  # remove unneeded rows from dataframe
  varstokeep <- row.names(final_model$importance)
  new_df_sub <- new_df[, varstokeep]
  
  # predict on new dataset
  xpredict <- predict(
    final_model
    , what = c(0.50, 0.75, 0.90)
    , newdata = new_df_sub
  )
  
  # concatenate "new dataset" response with predicted outcome (with uncertainty) 
  observed_response_variable <- colnames(new_df)[grep('^Y$|^p$', colnames(new_df))]
  
  x2 <- cbind(
    'Region' = regionName
    , 'Disease' = diseaseName
    , 'Lead_time' = new_df$Lead_time
    , 'Ensemble' = new_df$ensemble
    , 'Observed' = new_df[, observed_response_variable]
    , 'V3_Q50' = xpredict[,1]
    , 'V3_Q75' = xpredict[,2]
    , 'V3_Q90' = xpredict[,3]
  )
  
  # return output
  as.data.frame(x2)
}

# Make predictions -------------------------------------

# Growth anomalies - GBR, V3 predictions
V3_ga_gbr_cfs <- lapply(
  ga_gbr_forecast_df, function(x)
    predictNewCFS(
      final_model = GA_GBR_Model
      , new_df = x
      , regionName = 'GBR'
      , diseaseName = 'Growth anomalies'
      )
  )

V3_ga_gbr_cfs <- do.call('rbind', V3_ga_gbr_cfs)

# Growth anomalies - Pacific, V3 predictions
V3_ga_pac_cfs <- lapply(
  ga_pac_forecast_df, function(x)
    predictNewCFS(
      final_model = GA_Pacific_Model
      , new_df = x
      , regionName = 'Pacific'
      , diseaseName = 'Growth anomalies'
      )
)

V3_ga_pac_cfs <- do.call('rbind', V3_ga_pac_cfs)

# White syndromes - GBR, V3 predictions
V3_ws_gbr_cfs <- lapply(
  ws_gbr_forecast_df, function(x)
    predictNewCFS(
      final_model = WS_GBR_Model
      , new_df = x
      , regionName = 'GBR'
      , diseaseName = 'White syndromes'
      )
  )

V3_ws_gbr_cfs <- do.call('rbind', V3_ws_gbr_cfs)

# White syndromes - Pacific, V3 predictions
V3_ws_pac_cfs <- lapply(
  ws_pac_forecast_df, function(x)
    predictNewCFS(
      final_model = WS_Pacific_Model
      , new_df = x
      , regionName = 'Pacific'
      , diseaseName = 'White syndromes'
      )
  )

V3_ws_pac_cfs <- do.call('rbind', V3_ws_pac_cfs)

# combine data 
forec_forecasts <- bind_rows(
  V3_ga_gbr_cfs
  , V3_ga_pac_cfs
  , V3_ws_gbr_cfs
  , V3_ws_pac_cfs
)

# format data types
colNames_to_numeric <- colnames(forec_forecasts)[3:8]

forec_forecasts[, colNames_to_numeric] <- lapply(
  forec_forecasts[, colNames_to_numeric]
  , function(x) as.numeric(x)
)

# aggregate predictions across all ensemble members
forec_forecasts_agg <- forec_forecasts %>%
  group_by(Region, Disease, Lead_time, Observed) %>%
  summarise(
    V3_Q50 = quantile(V3_Q50, 0.90)
    , V3_Q75 = quantile(V3_Q75, 0.90)
    , V3_Q90 = quantile(V3_Q90, 0.90)
  ) %>%
  mutate(
    Prediction_precision = (V3_Q90 - V3_Q50)
    , Prediction_accuracy = (V3_Q75 - Observed)
  )

# save
save(forec_forecasts_agg, file = '../compiled_data/survey_data/validation_data/v3_forecasts_aggregated.RData')
