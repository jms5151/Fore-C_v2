# Model predictions for withheld validation data for nowcasts

# load library
library(ggplot2)
library(tidyverse)
library(quantregForest)

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

# load final model objects
source('./codes/Final_covariates_by_disease_and_region.R')

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

