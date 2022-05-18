# Re-run best models, save objects
library(quantregForest)

# load best models key
best_models_final <- read.csv('../model_selection_summary_results/parsimonious_best_models_by_disease_and_region.csv')

# directory paths
smote_dir <- '../compiled_data/survey_data/smote_datasets/'
model_objects_dir <- '../model_objects/'

# run models and save model objects
for(i in 1:nrow(best_models_final)){
  # format filenames for best models
  thsh <- ifelse(nchar(best_models_final$threshold[i]) == 2, best_models_final$threshold[i], paste0('0', best_models_final$threshold[i]))
  dz_name <- ifelse(best_models_final$name[i] == 'ws_pac', 'ws_pac_acr', best_models_final$name[i])
  train_name <- paste0(smote_dir, dz_name, '_smote_train_', thsh, '.csv')
  # test_name <- gsub('train', 'test', train_name)
  
  # load data
  df_train <- read.csv(train_name)
  # df_test <- read.csv(test_name)

  # format data for quantile regression
  dz_vars <- unlist(strsplit(best_models_final$Model_variables[i], split=', '))
  yVar <- ifelse(dz_name == 'ga_gbr' | dz_name == 'ws_gbr', 'Y', 'p')
  
  x_train <- df_train[, dz_vars] 
  y_train <- df_train[, yVar]

  # x_test <- df_test[, dz_vars] 
  # y_test <- df_test[, yVar]
  
  # run best model
  final_mod <- quantregForest(x_train, y_train, importance = TRUE)
  
  # save model
  modFileName <- paste0(model_objects_dir, best_models_final$name[i], ".rds")
  saveRDS(final_mod, file = modFileName)
}