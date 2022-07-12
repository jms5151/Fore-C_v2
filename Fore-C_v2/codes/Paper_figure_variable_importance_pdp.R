# Load libraries
library('tidyverse')
library('randomForest')
library('edarf') # devtools::install_github("zmjones/edarf", subdir = "pkg")
library('ggplot2')
library('cowplot')
library('patchwork')

# load custom functions
source("./codes/custom_functions/fun_plot_variable_importance.R")

# figure directories
figDirVarImp <- ""
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

# Create figure friendly covariate names
covar_names <- unique(c(ga_gbr_vars, ga_pac_vars, ws_gbr_vars, ws_pac_acr_vars))
covar_names <- data.frame('covars' = covar_names)
covar_names$covar_labels <- gsub('_', ' ', covar_names$covars)
covar_names$covar_labels <- gsub('Three Week ', 'Seasonal ', covar_names$covar_labels)
covar_names$covar_labels <- gsub('Long Term ', 'Chronic ', covar_names$covar_labels)
covar_names$covar_labels <- gsub('Kd ', 'turbidity ', covar_names$covar_labels)
covar_names$covar_labels <- gsub('Variability', 'variability', covar_names$covar_labels)
covar_names$covar_labels <- gsub('Median$', 'median', covar_names$covar_labels)
covar_names$covar_labels <- gsub('abund', 'density', covar_names$covar_labels)
covar_names$covar_labels <- gsub('^H ', 'Fish ', covar_names$covar_labels)
covar_names$covar_labels <- gsub('^Black.*', 'Coastal development', covar_names$covar_labels)
covar_names$covar_labels <- gsub('^SST.*', 'SST (90-day mean)', covar_names$covar_labels)

# for ws_gbr, coral cover = (plating, table)

# plotting function
var_imp_with_pdp_plot <- function(mod, vars, smote_data, plotTitle){
  
  # format data
  x <- as.data.frame(mod$importance)
  x$covars <- rownames(x)
  x <- x %>% left_join(covar_names)
  x$VarImp <- x$`%IncMSE`
  
  # create covariate levels in descending order based on variable importance
  newLevels <- x$covars[order(-x$VarImp)]  
  
  # create variable importance plot
  var_imp_plt <- ggplot(x, aes(x = reorder(covar_labels, VarImp), y = VarImp)) + 
    geom_point(size = 3) +
    ggtitle(plotTitle) +
    ylab('Variable importance (% increase MSE)') +
    xlab('') +
    # ylim(20, 70) +
    scale_x_discrete(expand = expansion(mult = c(.05, .2))) + # add space to top of plot within border
    coord_flip() +
    theme_bw() +
    theme(
      panel.grid.major.x = element_blank()
      , panel.grid.minor.x = element_blank()
      , axis.text.y = element_blank()
      # , axis.text.y = element_text(vjust = -6.5, hjust = 0, margin = margin(l = 1, r = -120))
      , axis.ticks.y = element_blank()
    )
  
  # create partial dependence data and plots
  pd_df <- partial_dependence(fit = mod,
                              vars = vars,
                              data = smote_data,
                              n = c(100, 200))
  
  pd_df2 <- pd_df %>%
    gather(key = covars, value = value, -prediction) %>%
    drop_na() %>% 
    left_join(covar_names)
  
  # set covariate levels determined above
  pd_df2$covars <- factor(pd_df2$covars, levels = newLevels)
  
  # create minimal PDP plots
  pd_plts <- ggplot(pd_df2, aes(x = value, y = prediction)) + 
    geom_line() +
    theme_void() +
    theme(
      panel.border = element_rect(colour = 'black', fill = NA)
      , strip.text.x = element_text(angle = 0, hjust = 0) #, vjust = 2 , size = 12
      # , strip.text.x = element_blank()# remove labels
    ) + 
    facet_wrap(~covar_labels, scales = 'free', ncol = 1) 
  
  # inset pdp plots within variable importance plot
  var_imp_plt + inset_element(p = pd_plts, left = 0.015, bottom = 0.05, right = 0.35, top = 0.95)
  
}

# Run and save plots for each disease-region -----------------------------------
# Manually adjust plot inset spacing in Inkscape/Illustrator if needed

# GA GBR
gagbr <- var_imp_with_pdp_plot(
  mod = GA_GBR_Model
  , vars = ga_gbr_vars
  , smote_data = ga_gbr_data
  , plotTitle = 'Growth anomalies\nGreat Barrier Reef, Australia'
)

ggsave(filename = '../../Figures/paper_figures/ga_gbr_covariates.pdf', width = 5, height = 7)

# GA Pacific
gapac <- var_imp_with_pdp_plot(
  mod = GA_Pacific_Model
  , vars = ga_pac_vars
  , smote_data = ga_pac_data
  , plotTitle = 'Growth anomalies\nU.S. Pacific'
)

ggsave(filename = '../../Figures/paper_figures/ga_pacific_covariates.pdf', width = 5, height = 7)

# WS GBR
wsgbr <- var_imp_with_pdp_plot(
  mod = WS_GBR_Model
  , vars = ws_gbr_vars
  , smote_data = ws_gbr_data
  , plotTitle = 'White syndromes\nGreat Barrier Reef, Australia'
)

ggsave(filename = '../../Figures/paper_figures/ws_gbr_covariates.pdf', width = 4, height = 6)

# WS Pacific
wspac <- var_imp_with_pdp_plot(
  mod = WS_Pacific_Model
  , vars = ws_pac_acr_vars
  , smote_data = ws_pac_acr_data
  , plotTitle = 'White syndromes\nU.S. Pacific'
)

ggsave(filename = '../../Figures/paper_figures/ws_pacific_covariates.pdf', width = 6, height = 10)


