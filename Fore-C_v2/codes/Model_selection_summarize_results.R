# Summarize results of QF model selection across thresholds with SMOTE data ---------
library(tidyverse)

# list files
results_dir <- "../model_selection_results/"

# list smote datafiles
filenames <- list.files(results_dir)

# create empty dataframe
best_models <- data.frame()

# parsimonious best model for each disease-region-threshold
for(i in filenames){
  df <- read.csv(paste0(results_dir, i))
  df <- subset(df, AdjR2 >= (max(AdjR2) - 0.01))
  df <- subset(df, Num_vars == min(Num_vars))
  df$name <- substr(i, 1, 6)
  df$threshold <- substr(i, 8, 9)
  best_models <- rbind(best_models, df)
}

# determine best threshold for each disease-region
best_models_final <- best_models %>%
  group_by(name) %>%
  filter(AdjR2 == max(AdjR2))

# save results
write.csv(best_models_final 
          , '../model_selection_summary_results/parsimonious_best_models_by_disease_and_region.csv'
          , row.names = F)
