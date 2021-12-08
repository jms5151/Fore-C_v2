# load data
load("../compiled_data/survey_data/GA_data_with_all_predictors.RData")
load("../compiled_data/survey_data/WS_data_with_all_predictors.RData")

# source custom functions
source("codes/custom_functions/fun_subset_and_filter_pseudo_replicate_surveys.R")
source("codes/custom_functions/fun_create_smote_datasets.R")

# source co-variates to test
source("codes/Initial_covariates_to_test_by_disease_and_region.R")

# set destination directory for smote datasets
dest_dir <- "../compiled_data/survey_data/smote_datasets/"

# load library
library(tidyverse)

# subset survey data
ga_pac <- subset_and_filter_pseudo_replicates(df = GA_data_with_all_predictors, 
                                              regionGBR = FALSE, 
                                              family = "Poritidae", 
                                              yvar = "p", 
                                              dz_vars = ga_pac_vars
                                              )


ga_gbr <- subset_and_filter_pseudo_replicates(df = GA_data_with_all_predictors, 
                                              regionGBR = TRUE, 
                                              family = NA, 
                                              yvar = "Y", 
                                              dz_vars = ga_gbr_vars
                                              )

ws_pac_acr <- subset_and_filter_pseudo_replicates(df = WS_data_with_all_predictors,
                                                  regionGBR = FALSE,
                                                  family = "Acroporidae",
                                                  yvar = "p",
                                                  dz_vars = ws_pac_acr_vars
                                                  )

ws_gbr <- subset_and_filter_pseudo_replicates(df = WS_data_with_all_predictors, 
                                              regionGBR = TRUE, 
                                              family = NA, 
                                              yvar = "Y", 
                                              dz_vars = ws_gbr_vars
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

count_thresh_levels <- c(0, 5, 10, 15) 

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
                         "_count"
                         )
      
    } else {
      fileName <- paste0(dest_dir, 
                         dz_names[i], 
                         "_with_predictors_smote_", 
                         thresh_levels[j] * 100, 
                         "_prev"
                         )
    }

    # create smote dataset
    smote_df <- create_smote_df(df = dz_dfs[[i]],
                                dz_vars = dzVars[[i]],
                                responseVar = response,
                                threshold = thresh_levels[j])
    # save as .Rdata file
    fileName1 <- paste0(fileName, ".RData")
    save(smote_df, file = fileName1)
    # save as .csv
    fileName2 <- paste0(fileName, ".csv")
    write.csv(smote_df, file = fileName2, row.names = F)
  }
}

