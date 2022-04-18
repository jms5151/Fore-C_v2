# Run forecasts using quantile regression models

# Load functions, model objects, and data --------------------------------------
# source custom functions
source("./codes/custom_functions/fun_split_df_by_n.R")
source("./codes/custom_functions/fun_quant_forest_predict.R")

# open final model objects
source("./codes/Final_covariates_by_disease_and_region.R")

# load data
load("../compiled_data/forecast_inputs/grid_with_dynamic_predictors.RData")

# Run model predictions --------------------------------------------------------

# GA GBR ----------
ga_gbr_df_long <- qf_new_data_subset(
  df = grid_with_dynamic_predictors
  , regionGBRtrue = TRUE
  , family = "all"
  , final_mod = GA_GBR_Model
  )

ga_gbr_list <- split_df_by_n(
  nrowSize = 100000
  , df = ga_gbr_df_long
  )

ga_gbr_results <- predict_on_list(
  dflist = ga_gbr_list
  , modName = GA_GBR_Model
  )
  
# GA Pacific ------
ga_pac_df_long <- qf_new_data_subset(
  df = grid_with_dynamic_predictors
  , regionGBRtrue = FALSE
  , family = "Poritidae"
  , final_mod = GA_Pacific_Model
)

ga_pac_list <- split_df_by_n(
  nrowSize = 100000
  , df = ga_pac_df_long
)

ga_pac_results <- predict_on_list(
  dflist = ga_pac_list
  , modName = GA_Pacific_Model
)

# WS GBR ----------
ws_gbr_df_long <- qf_new_data_subset(
  df = grid_with_dynamic_predictors
  , regionGBRtrue = TRUE
  , family = "plating"
  , final_mod = WS_GBR_Model
)

ws_gbr_list <- split_df_by_n(
  nrowSize = 100000
  , df = ws_gbr_df_long
)

ws_gbr_results <- predict_on_list(
  dflist = ws_gbr_list
  , modName = WS_GBR_Model
)

# WS Pacific ------
ws_pac_df_long <- qf_new_data_subset(
  df = grid_with_dynamic_predictors
  , regionGBRtrue = FALSE
  , family = "Acroporidae"
  , final_mod = WS_Pacific_Model
)

ws_pac_list <- split_df_by_n(
  nrowSize = 100000
  , df = ws_pac_df_long
)

ws_pac_results <- predict_on_list(
  dflist = ws_pac_list
  , modName = WS_Pacific_Model
)

# Check if previous predictions exist, and if so, load and rename
ga_filepath <- "../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ga_forecast.RData"
ws_filepath <- "../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ws_forecast.RData"

if(file.exists(ga_filepath) == TRUE){
  load(ga_filepath)
  ga_forecast_old <- ga_forecast
}

if(file.exists(ws_filepath) == TRUE){
  load(ws_filepath)
  ws_forecast_old <- ws_forecast
}

# combine data and save --------------------------------------------------------
# GA
ga_forecast <- bind_rows(ga_gbr_results, ga_pac_results) %>% 
  group_by(ID, Latitude, Longitude, Region, Date, type) %>%
  summarise(
    Lwr = quantile(LwrEstimate, 0.90)
    , value = quantile(estimate, 0.90)
    , Upr = quantile(UprEstimate, 0.90)
    )

# Make a percent
ga_forecast$value[ga_forecast$Region != "gbr"] <- ga_forecast$value[ga_forecast$Region != "gbr"] * 100
ga_forecast$Lwr[ga_forecast$Region != "gbr"] <- ga_forecast$Lwr[ga_forecast$Region != "gbr"] * 100
ga_forecast$Upr[ga_forecast$Region != "gbr"] <- ga_forecast$Upr[ga_forecast$Region != "gbr"] * 100

# Add alert levels
# 0 = No stress
# 1 = Watch
# 2 = Warning
# 3 = Alert Level 1
# 4 = Alert Level 2
ga_forecast$drisk <- NA
ga_forecast$drisk[ga_forecast$value >= 0 & ga_forecast$value <= 5] <- 0
ga_forecast$drisk[ga_forecast$value > 5 & ga_forecast$value <= 10] <- 1
ga_forecast$drisk[ga_forecast$value > 10 & ga_forecast$value <= 15] <- 2
ga_forecast$drisk[ga_forecast$value > 15 & ga_forecast$value <= 25] <- 3
ga_forecast$drisk[ga_forecast$value > 25] <- 4

# # GA GBR
# ga_forecast$drisk[ga_forecast$Region == "gbr" & ga_forecast$value >= 0 & ga_forecast$value <= 5] <- 0
# ga_forecast$drisk[ga_forecast$Region == "gbr" & ga_forecast$value > 5 & ga_forecast$value <= 10] <- 1
# ga_forecast$drisk[ga_forecast$Region == "gbr" & ga_forecast$value > 10 & ga_forecast$value <= 15] <- 2
# ga_forecast$drisk[ga_forecast$Region == "gbr" & ga_forecast$value > 15 & ga_forecast$value <= 25] <- 3
# ga_forecast$drisk[ga_forecast$Region == "gbr" & ga_forecast$value > 25] <- 4
# 
# # GA Pacific
# ga_forecast$drisk[ga_forecast$Region != "gbr" & ga_forecast$value >= 0.00 & ga_forecast$value <= 0.05] <- 0
# ga_forecast$drisk[ga_forecast$Region != "gbr" & ga_forecast$value > 0.05 & ga_forecast$value <= 0.10] <- 1
# ga_forecast$drisk[ga_forecast$Region != "gbr" & ga_forecast$value > 0.10 & ga_forecast$value <= 0.15] <- 2
# ga_forecast$drisk[ga_forecast$Region != "gbr" & ga_forecast$value > 0.15 & ga_forecast$value <= 0.25] <- 3
# ga_forecast$drisk[ga_forecast$Region != "gbr" & ga_forecast$value > 0.25] <- 4

if(exists("ga_forecast_old") == TRUE){
  minDate <- min(ga_forecast_old$Date)
  maxNowcastDate <- max(ga_forecast_old$Date[ga_forecast_old$type == "nowcast"])
  ga_forecast_old <- ga_forecast_old %>%
    filter(Date > minDate & Date <= maxNowcastDate)
  ga_forecast <- subset(ga_forecast, Date > maxNowcastDate)
  ga_forecast <- bind_rows(ga_forecast_old, ga_forecast)
}

# save
save(ga_forecast, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ga_forecast.RData")

# WS
ws_forecast <- bind_rows(ws_gbr_results, ws_pac_results) %>%
  group_by(ID, Latitude, Longitude, Region, Date, type) %>%
  summarise(
    Lwr = quantile(LwrEstimate, 0.90)
    , value = quantile(estimate, 0.90)
    , Upr = quantile(UprEstimate, 0.90)
  )

# Make a percent
ws_forecast$value[ws_forecast$Region != "gbr"] <- ws_forecast$value[ws_forecast$Region != "gbr"] * 100
ws_forecast$Lwr[ws_forecast$Region != "gbr"] <- ws_forecast$Lwr[ws_forecast$Region != "gbr"] * 100
ws_forecast$Upr[ws_forecast$Region != "gbr"] <- ws_forecast$Upr[ws_forecast$Region != "gbr"] * 100

# Add alert levels
ws_forecast$drisk <- NA

# WS GBR
ws_forecast$drisk[ws_forecast$Region == "gbr" & ws_forecast$value >= 0 & ws_forecast$value <= 1] <- 0
ws_forecast$drisk[ws_forecast$Region == "gbr" & ws_forecast$value > 1 & ws_forecast$value <= 5] <- 1
ws_forecast$drisk[ws_forecast$Region == "gbr" & ws_forecast$value > 5 & ws_forecast$value <= 10] <- 2
ws_forecast$drisk[ws_forecast$Region == "gbr" & ws_forecast$value > 10 & ws_forecast$value <= 20] <- 3
ws_forecast$drisk[ws_forecast$Region == "gbr" & ws_forecast$value > 20] <- 4

# WS Pacific
# ws_forecast$drisk[ws_forecast$Region != "gbr" & ws_forecast$value >= 0 & ws_forecast$value <= 0.01] <- 0
# ws_forecast$drisk[ws_forecast$Region != "gbr" & ws_forecast$value > 0.01 & ws_forecast$value <= 0.05] <- 1
# ws_forecast$drisk[ws_forecast$Region != "gbr" & ws_forecast$value > 0.05 & ws_forecast$value <= 0.10] <- 2
# ws_forecast$drisk[ws_forecast$Region != "gbr" & ws_forecast$value > 0.10 & ws_forecast$value <= 0.15] <- 3
# ws_forecast$drisk[ws_forecast$Region != "gbr" & ws_forecast$value > 0.15] <- 4

ws_forecast$drisk[ws_forecast$Region != "gbr" & ws_forecast$value >= 0 & ws_forecast$value <= 1] <- 0
ws_forecast$drisk[ws_forecast$Region != "gbr" & ws_forecast$value > 1 & ws_forecast$value <= 5] <- 1
ws_forecast$drisk[ws_forecast$Region != "gbr" & ws_forecast$value > 5 & ws_forecast$value <= 0] <- 2
ws_forecast$drisk[ws_forecast$Region != "gbr" & ws_forecast$value > 10 & ws_forecast$value <= 15] <- 3
ws_forecast$drisk[ws_forecast$Region != "gbr" & ws_forecast$value > 15] <- 4

if(exists("ws_forecast_old") == TRUE){
  minDate <- min(ws_forecast_old$Date)
  maxNowcastDate <- max(ws_forecast_old$Date[ws_forecast_old$type == "nowcast"])
  ws_forecast_old <- ws_forecast_old %>%
    filter(Date > minDate & Date <= maxNowcastDate)
  ws_forecast <- subset(ws_forecast, Date > maxNowcastDate)
  ws_forecast <- bind_rows(ws_forecast_old, ws_forecast)
}

# save
save(ws_forecast, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ws_forecast.RData")
