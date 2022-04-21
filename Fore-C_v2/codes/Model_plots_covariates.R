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

# create marginal effects plots (different from PDP) ---
source("./codes/Final_covariates_by_disease_and_region.R")

figDirME <- "../../Figures/Quantile_forests/marginal_effects_plots/"

marginal_effects_plot <- function(df, mod, model_covars, modName){
  df <- df[,model_covars]
  df_medians <- apply(df, 2, median)
  for(i in model_covars){
    if(i == 'Month'){
      i_seq <- seq(from = min(df[,i]), to = max(df[,i]), by = 1)
    } else {
      i_seq <- seq(from = min(df[,i]), to = max(df[,i]), length = 100)
    }
    df_medians_adj <- df_medians[!grepl(pattern = i, names(df_medians))]
    df_medians_adj <- as.data.frame(t(df_medians_adj))
    
    newdata <- data.frame(i_seq)
    colnames(newdata) <- i
    newdata_smote <- newdata %>%
      bind_cols(df_medians_adj)
    
    xpredict <- predict(mod,
                        what = c(0.05, 0.25, 0.50, 0.75, 0.95),
                        newdata = newdata_smote)
    
    filename = paste0(figDirME, modName, '_', i, '.pdf')
    pdf(filename, width = 8, height = 6)
    sdY <- max(sd(xpredict[,5]), 0.2, na.rm = T)
    maxY <- max(xpredict[,5]) + sdY 
    plot(i_seq, xpredict[,1], type = 'l', ylim = c(0, maxY), lty = 3, col = 'darkblue', lwd = 2, ylab = 'Marginal effect', xlab = gsub('_', ' ', i))
    lines(i_seq, xpredict[,2], type = 'l', lty = 2, col = 'blue', lwd = 2)
    lines(i_seq, xpredict[,3], type = 'l', lty = 1, lwd = 2)
    lines(i_seq, xpredict[,4], type = 'l', lty = 2, col = 'blue', lwd = 2)
    lines(i_seq, xpredict[,5], type = 'l', lty = 3, col = 'darkblue', lwd = 2)
    legend('topleft', bty = 'n', lty = c(3, 2, 1), lwd = c(2, 2, 2), col = c('darkblue', 'blue', 'black')
           , legend = c('5-95th Prediction Interval', '25-75th Prediction Interval', '50th quantile'))
    dev.off()
  }
  
}

load('../compiled_data/survey_data/smote_datasets/ga_pac_with_predictors_smote_0_prev.RData')
marginal_effects_plot(df = smote_df
                      , mod = GA_Pacific_Model
                      , model_covars = ga_pac_vars
                      , modName = 'ga_pac')

load('../compiled_data/survey_data/smote_datasets/ws_pac_acr_with_predictors_smote_0_prev.RData')
marginal_effects_plot(df = smote_df
                      , mod = WS_Pacific_Model
                      , model_covars = ws_pac_acr_vars
                      , modName = 'ws_pac_acr')

load('../compiled_data/survey_data/smote_datasets/ga_gbr_with_predictors_smote_5_count.RData')
marginal_effects_plot(df = smote_df
                      , mod = GA_GBR_Model
                      , model_covars = ga_gbr_vars
                      , modName = 'ga_gbr')

load('../compiled_data/survey_data/smote_datasets/ws_gbr_with_predictors_smote_5_count.RData')
marginal_effects_plot(df = smote_df
                      , mod = WS_GBR_Model
                      , model_covars = ws_gbr_vars
                      , modName = 'ws_gbr')


# # testing for pdp plots, not working
# source("./codes/custom_functions/fun_subset_and_split_df.R")
# 
# load('../compiled_data/survey_data/smote_datasets/ga_pac_with_predictors_smote_0_prev.RData')
# 
# x <- subset_and_split_sample(df = smote_df,
#                              vars = c("Month"
#                                       , "Median_colony_size"
#                                       , "CV_colony_size"
#                                       , "Poritidae_mean_cover"
#                                       , "H_abund"
#                                       , "SST_90dMean"
#                                       , "BlackMarble_2016_3km_geo.3"
#                                       , "Long_Term_Kd_Median"
#                                       , "Long_Term_Kd_Variability"
#                                       , "Three_Week_Kd_Median"
#                                       , "Three_Week_Kd_Variability"),
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
#         mod = ga_pac,
#         # covariates = "SST_90dMean"),
#         covar_dict = as.factor(row.names(as.data.frame(ga_pac$importance))))
