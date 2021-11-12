# load co-variates to test
source("./codes/Initial_covariates_to_test_by_disease_and_region.R")

# load functions 
source("./codes/custom_functions/fun_subset_and_split_df.R")
source("./codes/custom_functions/fun_create_data_frame.R")
source("./codes/custom_functions/fun_qf_custom_functions.R")

# set where results will be stored
results_dir <- "../model_selection_results/"

# list smote datafiles
filenames <- list.files("../compiled_data/survey_data/smote_datasets/", full.names = TRUE)

# run model selection
for(i in 1:length(filenames)){
  startTime <- Sys.time()
  # load data
  load(filenames[i]) # every df is called "smote_df"
  df_vars <- colnames(smote_df) 
  # determine response variables based on whether or not column names include "p"
  x <- df_vars[(df_vars %in% c("p"))]
  if(length(x) == 1){
    response <- "p"
  } else {
    response <- "Y"
  }
  # exclude names of columns that are not co-variates
  df_vars <- df_vars[!(df_vars %in% c("Health_status", "p", "Y", "class")) ]
  # create results file name
  xx <- substr(filenames[i], 45, nchar(filenames[i])-6)
  new_filename <- paste0(results_dir, xx, "_results.csv")
  # full model selection code
  mod_select(df = smote_df,
             dz_vars = df_vars,
             responseVar = response,
             varToKeep = 'Month',
             DFfileName = new_filename)
  endTime <- Sys.time()
  # include progress messages
  cat("finished", 
      i, 
      "of",
      length(filenames),
      "; Time lapsed = ",
      endTime - startTime,
      "\n")
  
}