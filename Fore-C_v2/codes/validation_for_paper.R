# Run model validation for nowcasts --------------------------------------------

# hard code directory and file loading
smote_dir <- '../compiled_data/survey_data/smote_datasets/'

GA_GBR_filepath <- paste0(smote_dir, 'ga_gbr_smote_test_15.csv')
GA_Pacific_filepath <- paste0(smote_dir, 'ga_pac_smote_test_20.csv')
WS_GBR_filepath <- paste0(smote_dir, 'ws_gbr_smote_test_10.csv')
WS_Pacific_filepath <- paste0(smote_dir, 'ws_pac_acr_smote_test_`05`0.csv')

ga_gbr_df <- read.csv(GA_GBR_filepath)
ga_pac_df <- read.csv(GA_Pacific_filepath)
ws_gbr_df <- read.csv(WS_GBR_filepath)
ws_pac_df <- read.csv(WS_Pacific_filepath)

# function to predict on new data 
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
    'Region' = regionName
    , 'Disease' = diseaseName
    , observed_response_variable = new_df[, observed_response_variable]
    , 'V3_Q50' = xpredict[,1]
    , 'V3_Q75' = xpredict[,2]
    , 'V3_Q90' = xpredict[,3]
    )
  
  # return output
  as.data.frame(x2)
}

# open final model objects
source('./codes/Final_covariates_by_disease_and_region.R')

library(quantregForest)

# predict
ws_nowcast <- predictNew(
  final_model = WS_Pacific_Model
  , new_df = ws_pac_df
  , regionName = 'Pacific'
  , diseaseName = 'White syndromes'
  )

# lapply and then add region-disease column?

plot(ws_nowcast$value, ws_nowcast$p, pch = 16)
abline(lm(ws_nowcast$p~ws_nowcast$value))