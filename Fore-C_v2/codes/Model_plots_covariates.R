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
