# load co-variates to test
source("./codes/Initial_covariates_to_test_by_disease_and_region.R")

# load functions 
source("./codes/custom_functions/fun_create_data_frame.R")
source("./codes/custom_functions/fun_qf_custom_functions.R")

# set where results will be stored
results_dir <- "../model_selection_results/"

# list smote datafiles
filenames <- list.files("../compiled_data/survey_data/smote_datasets/", full.names = TRUE)

# limit list to training data
filenames <- filenames[grep('train', filenames)]

# run model selection
for(i in length(filenames):1){
  # load data
  df_train <- read.csv(filenames[i])
  test_filename <- gsub('train', 'test', filenames[i])
  df_test <- read.csv(test_filename)
  
  # set disease name
  dz_name <- substr(filenames[i], 45, 50)
  
  # format data for quantile regression
  if(dz_name == 'ga_gbr'){
    dz_vars <- ga_gbr_vars
  } else if(dz_name == 'ga_pac') {
    dz_vars <- ga_pac_vars
  } else if(dz_name == 'ws_gbr') {
    dz_vars <- ws_gbr_vars
  } else {
    dz_vars <- ws_pac_acr_vars
  }
  
  x_train <- df_train[, dz_vars[2:length(dz_vars)]] 
  y_train <- df_train[, dz_vars[1]]
  
  x_test <- df_test[, dz_vars[2:length(dz_vars)]] 
  y_test <- df_test[, dz_vars[1]]
  
  # create results file name
  thresh <- substr(filenames[i], nchar(filenames[i])-5, nchar(filenames[i])-4)
  new_filename <- paste0(results_dir, dz_name, '_', thresh, "_results.csv")
  
  # full model selection code
  mod_select(
    x_train = x_train
    , y_train = y_train
    , x_test = x_test
    , y_test = y_test
    , dz_vars = dz_vars
    , DFfileName = new_filename
    )
  
  # include progress messages
  cat("finished", i, "of", length(filenames), as.character(Sys.time()), "\n")
  
}
