# load data
load("./compiled_data/survey_data/GA_data_with_all_predictors_slim.RData")
load("./compiled_data/survey_data/WS_data_with_all_predictors_slim.RData")

# source custom function
source("codes/custom_functions/fun_create_smote_datasets.R")

# source co-variates to test
source("codes/Initial_covariates_to_test_by_disease_and_region.R")

# set destination directory for smote datasets
dest_dir <- "./compiled_data/survey_data/smote_datasets/"

# subset data by region and family
ga_pac <- subset(GA_data_with_all_predictors_slim, 
                 Region != "GBR" & 
                   Family == "Poritidae"
                 )

ga_gbr <- subset(GA_data_with_all_predictors_slim, 
                 Region == "GBR"
                 )

ws_pac_acr <- subset(WS_data_with_all_predictors_slim, 
                     Region != "GBR" & 
                       Family == "Acroporidae"
                     )

ws_gbr <- subset(WS_data_with_all_predictors_slim, 
                 Region == "GBR"
                 )

# set data up to loop through 
dz_dfs <- list(ga_pac,
               ga_gbr,
               ws_pac_acr,
               ws_gbr
               )

dz_names <- list("ga_pac",
                 "ga_gbr",
                 "ws_pac_acr",
                 "ws_gbr"
                 )

dzVars <- list(ga_pac_vars,
               ga_gbr_vars,
               ws_pac_acr_vars,
               ws_gbr_vars
               )


region <- rep(c("pac", "gbr"), 2)

# set threshold levels to loop through, differs by region because of survey design
prev_thresh_levels <- c(0, 0.05, 0.10, 0.15, 0.20) 

count_thresh_levels <- c(0, 1, 5, 10, 15) 

# create SMOTE data sets
for(i in 1:length(dz_dfs)){
  # use different response variables based on region
  if(region[i] == "gbr"){
    thresh_levels <- count_thresh_levels
    response <- "Y"
  } else {
    thresh_levels <- prev_thresh_levels
    response <- "p"
  }
  for(j in 1:length(thresh_levels)){
    # use different filenames based on region
    if(region[i] == "gbr"){
      fileName <- paste0(dest_dir, 
                         dz_names[i], 
                         "_with_predictors_smote_", 
                         thresh_levels[j], 
                         "_count.RData"
                         )
    } else {
      fileName <- paste0(dest_dir, 
                         dz_names[i], 
                         "_with_predictors_smote_", 
                         thresh_levels[j] * 100, 
                         "_prev.RData"
                         )
    }

    # create smote dataset
    smote_df <- create_smote_df(df = dz_dfs[[i]],
                                dz_vars = dzVars[[i]],
                                responseVar = response,
                                threshold = thresh_levels[j])
    # save
    save(smote_df, file = fileName)
  }
}

