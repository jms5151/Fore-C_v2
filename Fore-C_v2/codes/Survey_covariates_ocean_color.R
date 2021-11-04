# load library
library(tidyverse)
library(modelr)

# load data
oc <- read.csv("raw_data/covariate_data/ocean_color/oc_matchup_columns_20211006_new_acute_metrics_survey_locations_new_cols_land.csv", head = T)

# format 
oc$Date <- as.Date(oc$Date, "%m/%d/%Y")

# create residual metrics
long_term_model <- lm(Long_Term_Chl_Median ~ Long_Term_Kd_Median, 
                      data = oc
                      )

three_week_model <- lm(Three_Week_Chl_Median ~ Three_Week_Kd_Median, 
                       data = oc
                       )

oc_lt_resids <- oc %>% 
  add_residuals(long_term_model)

oc$Long_Term_Median_Residual <- oc_lt_resids$resid

oc_3w_resids <- oc %>% 
  add_residuals(three_week_model)

oc$Three_Week_Median_Residual <- oc_3w_resids$resid

# create variability metrics
oc$Long_Term_Chl_Variability <- oc$Long_Term_Chl_90th - oc$Long_Term_Chl_Median
oc$Long_Term_Kd_Variability <- oc$Long_Term_Kd_90th - oc$Long_Term_Kd_Median

oc$Three_Week_Chl_Variability <- oc$Three_Week_Chl_90th - oc$Three_Week_Chl_Median
oc$Three_Week_Kd_Variability <- oc$Three_Week_Kd_90th - oc$Three_Week_Kd_Median

# list column names for acute metrics
acute_metrics <- colnames(oc)[grep(pattern = "^Acute", x = colnames(oc))]

# create presence/absence columns for acute metrics
new_acute_metrics <- paste0(acute_metrics, "_PA")

oc[new_acute_metrics] <- lapply(oc[,acute_metrics], function(x) ifelse(!is.na(x), 1, 0))

# subset metrics to test and save
ocean_color <- oc[, c("Date",
                      "Latitude",
                      "Longitude",
                      "Long_Term_Chl_Median",
                      "Long_Term_Chl_90th",
                      "Long_Term_Kd_Median",
                      "Long_Term_Kd_90th",
                      "Long_Term_Chl_Variability",
                      "Long_Term_Kd_Variability",
                      "Long_Term_Median_Residual",
                      "Three_Week_Chl_Median",
                      "Three_Week_Kd_Median",
                      "Three_Week_Chl_Variability",
                      "Three_Week_Kd_Variability",
                      "Three_Week_Median_Residual",
                      "Acute_Chla_4week",
                      "Acute_Kd_4week",
                      "Acute_Chla_8week",
                      "Acute_Kd_8week",
                      "Acute_Chla_12week",
                      "Acute_Kd_12week",
                      "Acute_Chla_4week_PA",
                      "Acute_Kd_4week_PA",
                      "Acute_Chla_8week_PA",
                      "Acute_Kd_8week_PA",
                      "Acute_Chla_12week_PA",
                      "Acute_Kd_12week_PA"
                      )]

save(ocean_color, file = "compiled_data/survey_covariate_data/surveys_ocean_color_metrics.RData")
