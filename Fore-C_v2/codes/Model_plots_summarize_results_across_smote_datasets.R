# load libraries
library(ggplot2)
library(tidyverse)

# load data
x <- read.csv("./model_selection_summary_results/qf_smote_summary.csv")

# format data for plotting
x2 <- x %>%
  gather(key = Sample_type,
         value = R2,
         AdjR2_insample:AdjR2_out_of_sample)

x2$Sample_type <- gsub("AdjR2_", "", x2$Sample_type)
x2$Sample_type <- gsub("_", " ", x2$Sample_type)

x2$selection <- gsub("_", " ", x2$selection)

x2$Disease_type <- gsub("_", " ", x2$Disease_type)

# plot
summary_plot <- ggplot(x2,
                       aes(x = Smote_threshold,
                           y = R2,
                           col = Sample_type,
                           linetype = selection
                           )
                       ) +
  geom_line() +
  geom_point() +
  facet_grid(~Disease_type, scales = "free_x") +
  theme_bw() +
  # xlab("SMOTE threshold") +
  labs(x = "SMOTE threshold", 
       y = "Adjusted R^2", 
       linetype = "Model selection", 
       col = "Sample type"
       )

ggsave(summary_plot,
       file = "../Figures/Quantile_forests/qf_summary.pdf",
       width = 12,
       height = 6)
