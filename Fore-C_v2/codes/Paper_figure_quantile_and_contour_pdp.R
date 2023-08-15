library(quantregForest)
library(tidyverse)
library(ggplot2)

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
covar_names <- data.frame('Variable_name' = covar_names)
covar_names$covar_labels <- gsub('_', ' ', covar_names$Variable_name)
covar_names$covar_labels <- gsub('Three Week ', 'Seasonal ', covar_names$covar_labels)
covar_names$covar_labels <- gsub('Long Term ', 'Chronic ', covar_names$covar_labels)
covar_names$covar_labels <- gsub('Kd ', 'turbidity ', covar_names$covar_labels)
covar_names$covar_labels <- gsub('Variability', 'variability', covar_names$covar_labels)
covar_names$covar_labels <- gsub('Median$', 'median', covar_names$covar_labels)
covar_names$covar_labels <- gsub('abund', 'density', covar_names$covar_labels)
covar_names$covar_labels <- gsub('^H ', 'Fish ', covar_names$covar_labels)
covar_names$covar_labels <- gsub('^Black.*', 'Coastal development', covar_names$covar_labels)
covar_names$covar_labels <- gsub('^SST.*', 'SST (90-day mean)', covar_names$covar_labels)

# functions to predict on new data & plot
pdpNewdf <- function(mod, df, y){
  # get median value for all covariates
  df_med <- df %>% summarise_all(median)
  # create sequence of values for covariate of interest
  N = 100
  coef_range <- seq(min(df[,y]), max(df[,y]), length.out = N)
  # create new dataframe to predict with range of values for y and constant for all others 
  newdf <- apply(df_med, 2, function(co) rep(co, each = N))
  newdf[,y] <- coef_range
  newdf <- as.data.frame(newdf)
  return(newdf)
}

genPDPdata <- function(mod, df){
  # get variables and 
  x <- as.data.frame(mod$importance)
  x <- x[order(x$`%IncMSE`, decreasing = T),]
  x$Variable_name <- rownames(x)
  x <- x %>% left_join(covar_names)
  facLevels <- x$covar_labels
  dfOut <- data.frame()
  for(i in 1:nrow(x)){
    # y = rownames(x)[i]
    y = x$Variable_name[i]
    newdf <- pdpNewdf(mod, df, y)
    # predict 
    xpredict <- predict(mod, what = c(0.50, 0.75, 0.90), newdata = newdf)
    x2 <- data.frame(Variable_name = y
                     , 'Variable_value' = newdf[,y]
                     , "Lwr" = xpredict[,1]
                     , "Median" = xpredict[,2]
                     , "Upr" = xpredict[,3]
                     )
    dfOut <- rbind(dfOut, x2)
  }
  dfOut <- dfOut %>% left_join(covar_names)
  dfOut$covar_labels <- factor(dfOut$covar_labels, levels = facLevels)
  return(dfOut)
}


pdpMultiplot <- function(mod, df, plotTitle, region){
  x <- genPDPdata(mod = mod, df = df)
  if(region == 'GBR'){
    yTitle <- 'Predicted density'
  } else {
    yTitle <- 'Predicted prevalence'
    # transform y-axis from 0-1 to 0-100%
    x$Median <- x$Median * 100
    x$Lwr <- x$Lwr * 100
    x$Upr <- x$Upr * 100
  }
  ggplot(x, aes(x = Variable_value, y = Median)) + 
    geom_line() + 
    geom_line(aes(y = Lwr), color = 'red', lty = 2) +
    geom_line(aes(y = Upr), color = 'red', lty = 2) +
    facet_wrap(~covar_labels, scales = 'free_x') +
    theme_bw() + 
    xlab('') +
    ylab(yTitle) +
    ggtitle(plotTitle)
}

# plot and save
pdpMultiplot(mod = GA_Pacific_Model, df = ga_pac_data, plotTitle = 'Growth anomalies, U.S. Pacific', region = 'Pacific')
ggsave(filename = '../../Figures/paper_figures/final/ga_pac_pdp_multi.pdf', width = 8, height = 5.5)

pdpMultiplot(mod = WS_Pacific_Model, df = ws_pac_acr_data, plotTitle = 'White syndromes, U.S. Pacific', region = 'Pacific')
ggsave(filename = '../../Figures/paper_figures/final/ws_pac_pdp_multi.pdf', width = 8, height = 5.5)

pdpMultiplot(mod = GA_GBR_Model, df = ga_gbr_data, plotTitle = 'Growth anomalies, GBR', region = 'GBR')
ggsave(filename = '../../Figures/paper_figures/final/ga_gbr_pdp_multi.pdf', width = 8, height = 5.5)

pdpMultiplot(mod = WS_GBR_Model, df = ws_gbr_data, plotTitle = 'White syndromes, GBR', region = 'GBR')
ggsave(filename = '../../Figures/paper_figures/final/ws_gbr_pdp_multi.pdf', width = 8, height = 5.5)
