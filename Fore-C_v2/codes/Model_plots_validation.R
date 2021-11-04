# load data
# model results
qf_results_filenames <- list.files("./model_selection_results/", full.names = TRUE)

# list smote datafiles
smote_filenames <- list.files("./compiled_data/survey_data/smote_datasets/", full.names = TRUE)

# load validation data
load("./compiled_data/survey_data/GA_data_with_all_predictors_pseudo_replicates.RData")
load("./compiled_data/survey_data/WS_data_with_all_predictors_pseudo_replicates.RData")

# load functions 
source("./codes/custom_functions/fun_subset_and_split_df.R")
source("./codes/custom_functions/fun_create_data_frame.R")
source("./codes/custom_functions/fun_qf_custom_functions.R")

# set up data and filepaths
summary_file_name <- "./model_selection_summary_results/qf_smote_summary.csv"

create_data_frame(fileName = summary_file_name,
                  listColumns = c("Disease_type",
                                  "Smote_threshold",
                                  "selection",
                                  "AdjR2_insample",
                                  "AdjR2_withheld_sample",
                                  "AdjR2_out_of_sample",
                                  "Covariates"
                                  )
                  )

model_objects_dir = "./model_objects/"
figures_dir <- "../Figures/Quantile_forests/validation/"

# loop through all smote datasets
for(i in 1:length(qf_results_filenames)){
  # read file
  df <- read.csv(qf_results_filenames[i])
  load(smote_filenames[i])
  # create dynamic variable names
  full_name <- gsub("./model_selection_results/|_with_predictors_smote_|0|1|5|10|15|20|_count_|results|_prev_|.csv", "", qf_results_filenames[i])
  plot_name <- gsub("_", " ", full_name)
  location <- gsub("ga_|ws_|acr_", "", full_name)
  smote_thresh <- gsub("./model_selection_results/|ga_gbr|ga_pac|ws_gbr|ws_pac_acr|_with_predictors_smote_|_count_|results|_prev_|.csv", "", qf_results_filenames[i])
  if(location == "gbr"){
    responseVar <- "Y"
  } else {
    responseVar <- "p"
  }
  for(j in 1:2){
    # select covariates of best model
    if(j == 1){
      best_covars <- select_best_mod_covars(df)
      name2 <- "overall_best"
    } else {
      best_covars <- select_best_parsimonious_mod_covars(df)
      name2 <- "parsimonious_best"
    }
    # turn covariates string into vector
    dz_vars <- strsplit(best_covars, ", ")[[1]]
    # split data 75/25
    final_df <- subset_and_split_sample(df = smote_df, 
                                        vars = dz_vars, 
                                        yVar = responseVar)
    # run model on test subset
    final_mod <- quantregForest(final_df[[1]],
                                unlist(final_df[[2]]),
                                importance = TRUE)
    # save model
    modFileName <- paste0(model_objects_dir, full_name, "_", name2, "_smote_", smote_thresh, ".rds")
    saveRDS(final_mod, file = modFileName)
    # training predictions
    train_predictions <- predict(final_mod,
                                 what = c(0.05, 0.75, 0.95),
                                 newdata = final_df[[1]])
    
    train_plot <- plot_with_marginal_distribution(y_obs = unlist(final_df[[2]]),
                                                  predictions_list = train_predictions,
                                                  plotTitle = "In sample")
    
    train_adjR2 <- round(summary(lm(train_predictions[, 2] ~ unlist(final_df[[2]])))$adj.r.squared, 2)
    # testing predictions
    test_predictions <- predict(final_mod,
                                what = c(0.05, 0.75, 0.95),
                                newdata = final_df[[3]])
    
    test_plot <- plot_with_marginal_distribution(y_obs = unlist(final_df[[4]]),
                                                 predictions_list = test_predictions,
                                                 plotTitle = "Withheld sample")
    
    test_adjR2 <- round(summary(lm(test_predictions[, 2] ~ unlist(final_df[[4]])))$adj.r.squared, 2)
    
    # OOS predictions
    if(full_name == "ga_pac"){
      oos_dat <- subset(GA_data_with_all_predictors_pseudo_replicates, Region != "GBR" & Family == "Poritidae")
    } else if(full_name == "ga_gbr"){
      oos_dat <- subset(GA_data_with_all_predictors_pseudo_replicates, Region == "GBR")
    } else if(full_name == "ws_pac_acr"){
      oos_dat <- subset(WS_data_with_all_predictors_pseudo_replicates, Region != "GBR" & Family == "Acroporidae")
    } else if(full_name == "ws_gbr"){
      oos_dat <- subset(WS_data_with_all_predictors_pseudo_replicates, Region == "GBR")
    }
    oos_sub <- oos_subset(OOSdata = oos_dat,
                          responseVar = responseVar,
                          dz_vars = dz_vars)

    oos_predictions <- predict(final_mod,
                               what = c(0.05, 0.75, 0.95),
                               newdata = oos_sub[[1]])
    
    oos_plot <- plot_with_marginal_distribution(y_obs = unlist(oos_sub[[2]]),
                                                predictions_list = oos_predictions,
                                                plotTitle = "Out of sample")
    
    oos_adjR2 <- round(summary(lm(oos_predictions[, 2] ~ unlist(oos_sub[[2]])))$adj.r.squared, 2)
    
    # arrange plots and save
    validation_multiplot <- ggarrange(train_plot,
                                      test_plot,
                                      oos_plot,
                                      nrow = 1
                                      )
    
    validation_multiplot <- annotate_figure(validation_multiplot,
                                            top = text_grob(paste0(plot_name, 
                                                                   " smote ", 
                                                                   smote_thresh
                                                                   ), 
                                                            face = "bold",
                                                            size = 14
                                                            )
                                            )
    
    plot_filepath <- paste0(figures_dir, full_name, "_", name2, "_smote_", smote_thresh, ".pdf")
    
    ggsave(validation_multiplot, 
           file = plot_filepath, 
           width = 12, 
           height = 5.5
           )
    
    # save data
    tmp_df <- data.frame(full_name, 
                         smote_thresh,
                         name2,
                         train_adjR2,
                         test_adjR2,
                         oos_adjR2,
                         best_covars
                         )
    
    write.table(tmp_df, 
                file = summary_file_name, 
                row.names = F, 
                sep = ",", 
                col.names = !file.exists(summary_file_name), 
                append = T)
  }
}    

# # GA Pacific model ----------------------------------------
# ga_pac_leftout <- subset(GA_data_with_all_predictors_pseudo_replicates, Region != "GBR" & Family == "Poritidae")
# 
# # final model
# final_mod(full_name = "GA_Pacific_smote",
#           df = ga_pac_smote,
#           responseVar = "p",
#           OOSdata = ga_pac_leftout)
# 
# # GA GBR model ----------------------------------------
# ga_gbr_leftout <- subset(GA_data_with_all_predictors_pseudo_replicates, Region == "GBR")
# 
# # final model
# final_mod(full_name = "GA_GBR_smote",
#           df = ga_gbr_smote,
#           responseVar = "Y",
#           OOSdata = ga_gbr_leftout)
# 
# # WS Pacific model ----------------------------------------
# ws_pac_acr_leftout <- subset(WS_data_validation_smote, Region != "GBR" & Family == "Acroporidae")
# 
# # final model
# final_mod(full_name = "WS_Pacific_smote",
#           df = ws_pac_acr_smote,
#           responseVar = "p",
#           OOSdata = ws_pac_acr_leftout)
# 
# # WS GBR model ----------------------------------------
# ws_gbr_leftout <- subset(WS_data_validation_smote, Region == "GBR")
# 
# # final model
# final_mod(full_name = "WS_GBR_smote",
#           df = ws_gbr_smote,
#           responseVar = "Y",
#           OOSdata = ws_gbr_leftout)
# 

