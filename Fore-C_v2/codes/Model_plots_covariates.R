# load custom functions
source("./codes/custom_functions/fun_plot_variable_importance.R")

# figure directories
figDirVarImp <- "../../Figures/Quantile_forests/variable_importance/"
figDirPDP <- "../../Figures/Quantile_forests/PDP/"

# # load data --------------------------------
# best_models_final <- read.csv('../model_selection_summary_results/parsimonious_best_models_by_disease_and_region.csv')

# mods <- read.csv("../model_selection_summary_results/parsimonious_best_models_by_disease_and_region.csv")
# 
# for(i in 1:nrow(mods)){
#   # create file path
#   mod_obj_name <- paste(mods$Disease_type[i],
#                         mods$selection[i],
#                         "smote",
#                         mods$Smote_threshold[i],
#                         sep = "_")
#   
#   filePath <- paste0("../model_objects/",
#                      mod_obj_name,
#                      ".rds")
#   # read model object
#   x <- readRDS(filePath)
#   # rename model object in environment
#   assign(mods$Disease_type[i], x)
# }

# load model objects -------------------------------
# open final model objects
source("./codes/Final_covariates_by_disease_and_region.R")

# load training data for PDP plots ----------------
smote_dir <- '../compiled_data/survey_data/smote_datasets/'
ga_gbr_data <- read.csv(paste0(smote_dir, 'ga_gbr_smote_train_15.csv'))
ga_pac_data <- read.csv(paste0(smote_dir, 'ga_pac_smote_train_15.csv'))
ws_gbr_data <- read.csv(paste0(smote_dir, 'ws_gbr_smote_train_10.csv'))
ws_pac_acr_data <- read.csv(paste0(smote_dir, 'ws_pac_acr_smote_train_05.csv'))

# objects to loop through ------------------------------------------------------
mods_list <- list(GA_GBR_Model,
                  GA_Pacific_Model,
                  WS_GBR_Model,
                  WS_Pacific_Model)

mods_names_list <- list("ga_gbr",
                        "ga_pac",
                        "ws_gbr",
                        "ws_pac_acr")

yLimits <- c(30, 0.31, 7, 0.20)

# plot variable importance -----------------------------------------------------
for(j in 1:length(mods_names_list)){
  plot_var_imp(mod_obj = mods_list[[j]], 
               mod_name = mods_names_list[j], 
               fig_dir = figDirVarImp)
  }

# PDP plots --------------------------------------------------------------------
# This is the most straightforward way to create a PDP plot
library(randomForest)
ga_pac_rf <- GA_Pacific_Model
class(ga_pac_rf) <- 'randomForest'
partialPlot(x = ga_pac_rf, pred.data = ga_gbr_data, x.var = 'Fish_abund', lwd = 2)

# This is an alternative way to create a PDP plot
library(pdp)
library(ggplot2)
pcov_part <- partial(GA_Pacific_Model, pred.var = c("Poritidae_mean_cover"), chull = TRUE)
autoplot(pcov_part, contour = TRUE)

# # Not using but useful code --------------------------------------------------
# # create marginal effects plots (different from PDP) 
# source("./codes/Final_covariates_by_disease_and_region.R")
# 
# figDirME <- "../../Figures/Quantile_forests/marginal_effects_plots/"
# 
# marginal_effects_plot <- function(df, mod, model_covars, modName){
#   df <- df[,model_covars]
#   df_medians <- apply(df, 2, median)
#   for(i in model_covars){
#     if(i == 'Month'){
#       i_seq <- seq(from = min(df[,i]), to = max(df[,i]), by = 1)
#     } else {
#       i_seq <- seq(from = min(df[,i]), to = max(df[,i]), length = 100)
#     }
#     df_medians_adj <- df_medians[!grepl(pattern = i, names(df_medians))]
#     df_medians_adj <- as.data.frame(t(df_medians_adj))
#     
#     newdata <- data.frame(i_seq)
#     colnames(newdata) <- i
#     newdata_smote <- newdata %>%
#       bind_cols(df_medians_adj)
#     
#     xpredict <- predict(mod,
#                         what = c(0.05, 0.25, 0.50, 0.75, 0.95),
#                         newdata = newdata_smote)
#     
#     filename = paste0(figDirME, modName, '_', i, '.pdf')
#     pdf(filename, width = 8, height = 6)
#     sdY <- max(sd(xpredict[,5]), 0.2, na.rm = T)
#     maxY <- max(xpredict[,5]) + sdY 
#     plot(i_seq, xpredict[,1], type = 'l', ylim = c(0, maxY), lty = 3, col = 'darkblue', lwd = 2, ylab = 'Marginal effect', xlab = gsub('_', ' ', i))
#     lines(i_seq, xpredict[,2], type = 'l', lty = 2, col = 'blue', lwd = 2)
#     lines(i_seq, xpredict[,3], type = 'l', lty = 1, lwd = 2)
#     lines(i_seq, xpredict[,4], type = 'l', lty = 2, col = 'blue', lwd = 2)
#     lines(i_seq, xpredict[,5], type = 'l', lty = 3, col = 'darkblue', lwd = 2)
#     legend('topleft', bty = 'n', lty = c(3, 2, 1), lwd = c(2, 2, 2), col = c('darkblue', 'blue', 'black')
#            , legend = c('5-95th Prediction Interval', '25-75th Prediction Interval', '50th quantile'))
#     dev.off()
#   }
#   
# }
# 
# load('../compiled_data/survey_data/smote_datasets/ga_pac_with_predictors_smote_0_prev.RData')
# marginal_effects_plot(df = smote_df
#                       , mod = GA_Pacific_Model
#                       , model_covars = ga_pac_vars
#                       , modName = 'ga_pac')
# 
# load('../compiled_data/survey_data/smote_datasets/ws_pac_acr_with_predictors_smote_0_prev.RData')
# marginal_effects_plot(df = smote_df
#                       , mod = WS_Pacific_Model
#                       , model_covars = ws_pac_acr_vars
#                       , modName = 'ws_pac_acr')
# 
# load('../compiled_data/survey_data/smote_datasets/ga_gbr_with_predictors_smote_5_count.RData')
# marginal_effects_plot(df = smote_df
#                       , mod = GA_GBR_Model
#                       , model_covars = ga_gbr_vars
#                       , modName = 'ga_gbr')
# 
# load('../compiled_data/survey_data/smote_datasets/ws_gbr_with_predictors_smote_5_count.RData')
# marginal_effects_plot(df = smote_df
#                       , mod = WS_GBR_Model
#                       , model_covars = ws_gbr_vars
#                       , modName = 'ws_gbr')
