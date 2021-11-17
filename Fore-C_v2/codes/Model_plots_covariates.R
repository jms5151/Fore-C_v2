# load custom functions
source("./codes/custom_functions/fun_plot_variable_importance.R")

# figure directories
figDirVarImp <- "../../Figures/Quantile_forests/variable_importance/"
figDirPDP <- "../../Figures/Quantile_forests/PDP/"

# load data --------------------------------
mods <- read.csv("../model_selection_summary_results/parsimonious_best_models_by_disease_and_region.csv")

for(i in 1:nrow(mods)){
  # create file path
  mod_obj_name <- paste(mods$Disease_type[i],
                        mods$selection[i],
                        "smote",
                        mods$Smote_threshold[i],
                        sep = "_")
  
  filePath <- paste0("../model_objects/",
                     mod_obj_name,
                     ".rds")
  # read model object
  x <- readRDS(filePath)
  # rename model object in environment
  assign(mods$Disease_type[i], x)
}

# model objects to loop through -------------------------
mods_list <- list(ga_gbr,
                  ga_pac,
                  ws_gbr,
                  ws_pac_acr)

mods_names_list <- list("ga_gbr",
                        "ga_pac",
                        "ws_gbr",
                        "ws_pac_acr")

# plot variable importance ------------------------------
for(j in 1:length(mods_names_list)){
  plot_var_imp(mod_obj = mods_list[[j]], 
               mod_name = mods_names_list[j], 
               fig_dir = figDirVarImp)
}

# # testing for pdp plots, not working
# source("./codes/custom_functions/fun_subset_and_split_df.R")
# 
# x <- subset_and_split_sample(df = smote_df, 
#                              vars = c("Long_Term_Kd_Median",
#                                       "CV_colony_size",
#                                       "H_abund",
#                                       "BlackMarble_2016_3km_geo.3",
#                                       "Poritidae_mean_cover",
#                                       "Winter_condition",
#                                       "Hot_snaps",
#                                       "Month",
#                                       "Median_colony_size",
#                                       "SST_90dMean"), 
#                              yVar = "p")
# 
# partialPlot(ga_pac, x[[3]], x.var = "CV_colony_size")
# 
# remotes::install_github("KevinSee/qRfish")
# library(qRfish)
# 
# load("../compiled_data/survey_data/smote_datasets/ga_pac_with_predictors_smote_5_prev.RData")
# 
# pdpPlot(data = smote_df,
#         mod = ga_pac[[1]],
#         # covariates = "SST_90dMean",
#         covar_dict = as.factor(row.names(as.data.frame(ga_pac$importance))))
