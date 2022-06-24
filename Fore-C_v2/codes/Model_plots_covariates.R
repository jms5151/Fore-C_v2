# load custom functions
source("./codes/custom_functions/fun_plot_variable_importance.R")

# figure directories
figDirVarImp <- "../../Figures/Quantile_forests/variable_importance/"
figDirPDP <- "../../Figures/Quantile_forests/PDP/"

# load model objects -------------------------------
# open final model objects
source("./codes/Final_covariates_by_disease_and_region.R")

# load training data for PDP plots ----------------
smote_dir <- '../compiled_data/survey_data/smote_datasets/'
ga_gbr_data <- read.csv(paste0(smote_dir, 'ga_gbr_smote_train_15.csv'))
ga_pac_data <- read.csv(paste0(smote_dir, 'ga_pac_smote_train_20.csv'))
ws_gbr_data <- read.csv(paste0(smote_dir, 'ws_gbr_smote_train_10.csv'))
ws_pac_acr_data <- read.csv(paste0(smote_dir, 'ws_pac_acr_smote_train_10.csv'))

# objects to loop through ------------------------------------------------------
mods_list <- list(GA_GBR_Model,
                  GA_Pacific_Model,
                  WS_GBR_Model,
                  WS_Pacific_Model)

mods_names_list <- list("ga_gbr",
                        "ga_pac",
                        "ws_gbr",
                        "ws_pac_acr")

train_dfs <- list(ga_gbr_data
                  , ga_pac_data
                  , ws_gbr_data
                  , ws_pac_acr_data)

covars_list <- list(ga_gbr_vars
                    , ga_pac_vars
                    , ws_gbr_vars
                    , ws_pac_acr_vars)

yLimits <- c(30, 0.31, 7, 0.20)

# plot variable importance -----------------------------------------------------
for(j in 1:length(mods_names_list)){
  plot_var_imp(mod_obj = mods_list[[j]], 
               mod_name = mods_names_list[j], 
               fig_dir = figDirVarImp)
  }

varImpPlot(WS_GBR_Model
           , scale = TRUE
           , main = ''
           , xlab = ''
           , pch = 16
           , cex = 1.1
           , pt.cex = 1.5
           , type = 1 # variable importance, 2 = node impurity
           , labels = ''
           )
title(
  main = 'White syndromes\nGreat Barrier Reef, Australia'
  , xlab = 'Variable importance (% increase MSE)'
  )

# mtext("Experimenter pre-conditioning", 1, at=par("usr")[1])

x <- as.data.frame(WS_GBR_Model$importance)
x$covars <- gsub('_', ' ', rownames(x))
x$covars <- gsub('Fish abund', 'Fish density', x$covars)
x$covars <- gsub('Three Week Kd Variability', 'Seasonal turbidity variability', x$covars)
x$VarImp <- x$`%IncMSE`

library(ggplot2)

ggplot(x, aes(x = reorder(covars, VarImp), y=VarImp)) + 
  geom_point(size = 3) +
  ggtitle('White syndromes\nGreat Barrier Reef, Australia') +
  ylab('Variable importance (% increase MSE)') +
  xlab('') +
  ylim(20, 70) +
  coord_flip() +
  theme_bw() +
  theme(
    panel.grid.major.x = element_blank()
    , panel.grid.minor.x = element_blank()
    , axis.text.y = element_text(vjust = -2.5, hjust = 0, margin = margin(l = 1, r = -120))
    , axis.ticks.y = element_blank()
    ) 


# PDP plots --------------------------------------------------------------------
library(randomForest)

for(k in 1:length(mods_names_list)){
  # turn model to random forest object and list covariates in model
  mod <- mods_list[[k]]
  class(mod) <- 'randomForest'
  covars <- covars_list[[k]]
  # plot PDP for each covariate in model
  for(l in 1:length(covars)){
    fileName <- paste0(figDirPDP, mods_names_list[[k]], '_', covars[l], '.pdf')
    pdf(fileName, height = 8, width = 12)
    partialPlot(x = mod
                , pred.data = train_dfs[[k]]
                , x.var = covars[l]
                , lwd = 2
                , xlab = covars[l]
                , ylab = 'Marginal impact'
                , main = ''
                )
    dev.off()
    cat('Finished', mods_names_list[[k]], covars[l], '\n')
  }
}
