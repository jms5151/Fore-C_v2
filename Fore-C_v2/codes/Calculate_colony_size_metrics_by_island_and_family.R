# calculate colony size median and coefficient of variation by island and family
# load libraries
# library(data.table)

# load data
# source("codes/initial_survey_formatting.R")

df <- rbindlist(list(
  esd0812[, c("Island", 
              "Family", 
              "Colonylength"
              )
          ],
  esd1317[, c("Island", 
              "Family", 
              "Colonylength"
              )
          ],
  hicordis[, c("Island", 
               "Family", 
               "Colony_length"
               )
           ]
  ), 
  use.names = F
  )

median_sizes <- df %>%
  group_by(Island, Family) %>%
  summarize(Island_median_colony_size = median(Colonylength, na.rm = T),
            Island_colony_size_CV = sd(Colonylength, na.rm = T)/mean(Colonylength, na.rm = T)) %>%
  filter(Family == "Acroporidae" | Family == "Poritidae")

save(median_sizes, file = "compiled_data/survey_data/median_colony_sizes_by_island.RData")