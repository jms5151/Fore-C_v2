# Figure to show summary results of QF model selection across thresholds with SMOTE data ---------
library(tidyverse)
library(wesanderson)

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

best_models$Model <- gsub('ga_gbr', 'Growth anomalies, Great Barrier Reef', best_models$name)
best_models$Model <- gsub('ga_pac', 'Growth anomalies, U.S. Pacific', best_models$Model)
best_models$Model <- gsub('ws_gbr', 'White syndromes, Great Barrier Reef', best_models$Model)
best_models$Model <- gsub('ws_pac', 'White syndromes, U.S. Pacific', best_models$Model)

# format order
levs <- c('White syndromes, Great Barrier Reef', 'White syndromes, U.S. Pacific', 'Growth anomalies, Great Barrier Reef', 'Growth anomalies, U.S. Pacific')
best_models$Model <- factor(best_models$Model, levels = levs)

smote_select <- ggplot(best_models, aes(x = as.factor(threshold), y = AdjR2, pch = Model, color = Model)) + 
  geom_point(size = 5) + 
  scale_color_manual(values = rev(wes_palette('Zissou1', n = 4))) +
  theme_bw() + 
  ylab(expression('Adjusted R'^2)) +
  xlab('SMOTE threshold') +
  # ylim(0,1) +
  theme(legend.position = c(.75, 0.2))

ggsave(filename = '../../Figures/paper_figures/final/smote_summary.pdf', height = 5, width = 6.5,
       plot = smote_select)
