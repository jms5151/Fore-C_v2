# load libraries
library(ggplot2)
library(tidyverse)

# load data
x <- read.csv("../model_selection_summary_results/qf_smote_summary.csv")

# format data for plotting
x2 <- x %>%
  filter(selection == "parsimonious_best") %>%
  group_by(Disease_type) %>%
  filter(AdjR2_withheld_sample == max(AdjR2_withheld_sample)) %>%
  filter(AdjR2_insample == max(AdjR2_insample)) # needed if there's a tie in withheld sample R2


# save
write.csv(x2, 
          "../model_selection_summary_results/parsimonious_best_models_by_disease_and_region.csv", 
          row.names = F)
