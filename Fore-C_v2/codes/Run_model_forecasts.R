# Run forecasts using quantile regression models

source("./codes/custom_functions/fun_quant_forest_predict.R")

# open final model objects
source("./codes/Final_covariates_by_disease_and_region.R")

# set up directory filepaths
forecast_dir <- "../compiled_data/forecast_inputs/"
x <- list.files(forecast_dir)
x <- x[grep(".RData", x)]
forecast_save <- "../compiled_data/forecast_outputs/"

start_time <- Sys.time()
for (i in 1:length(x)){
  # load data
  fileName <- paste0(forecast_dir, x[i])
  y <- load(fileName)
  df <- get(y)
  # # GA Pacific
  # qf_predict(df = df,
  #            regionGBRtrue = FALSE,
  #            family = "Poritidae",
  #            final_mod = GA_Pacific_Model,
  #            name = "ga_pac",
  #            save_dir = forecast_save,
  #            fileName2 = x[i])
  # # WS Pacific
  # qf_predict(df = df,
  #            regionGBRtrue = FALSE,
  #            family = "Acroporidae",
  #            final_mod = WS_Pacific_Model,
  #            name = "ws_pac",
  #            save_dir = forecast_save,
  #            fileName2 = x[i])
  # GA GBR
  qf_predict(df = df,
             regionGBRtrue = TRUE,
             family = "",
             final_mod = GA_GBR_Model,
             name = "ga_gbr",
             save_dir = forecast_save,
             fileName2 = x[i])
  # WS GBR
  qf_predict(df = df,
             regionGBRtrue = TRUE,
             family = "",
             final_mod = WS_GBR_Model,
             name = "ws_gbr",
             save_dir = forecast_save,
             fileName2 = x[i])
}
end_time <- Sys.time()
end_time - start_time

## forecasts
# aggregate these datasets for 5km pixels
forecast_save <- "../compiled_data/forecast_outputs/"
outputs <- list.files(forecast_save)
outputs <- paste0(forecast_save, outputs)

ga_outputs <- outputs[grep("ga", outputs)]
ws_outputs <- outputs[grep("ws", outputs)]

aggregate_predictions <- function(outputs_list){
  df <- data.frame()
  for(i in 1:length(outputs_list)){
    x <- load(outputs_list[i])
    y <- get(x)
    y$Date <- as.Date(y$Date, "%Y-%m-%d")
    df <- rbind(df, y)
  }
  df
}

# ga forecasts
ga_forecast <- aggregate_predictions(ga_outputs)

# add alert levels
# 0 = No stress
# 1 = Watch
# 2 = Warning
# 3 = Alert Level 1
# 4 = Alert Level 2

# GA GBR
ga_forecast$drisk <- NA
ga_forecast$drisk[ga_forecast$Region == "gbr" & ga_forecast$value >= 0 & ga_forecast$value <= 5] <- 0
ga_forecast$drisk[ga_forecast$Region == "gbr" & ga_forecast$value > 5 & ga_forecast$value <= 10] <- 1
ga_forecast$drisk[ga_forecast$Region == "gbr" & ga_forecast$value > 10 & ga_forecast$value <= 15] <- 2
ga_forecast$drisk[ga_forecast$Region == "gbr" & ga_forecast$value > 15 & ga_forecast$value <= 25] <- 3
ga_forecast$drisk[ga_forecast$Region == "gbr" & ga_forecast$value > 25] <- 4

# GA Pacific
ga_forecast$drisk[ga_forecast$Region != "gbr" & ga_forecast$value >= 0.00 & ga_forecast$value <= 0.05] <- 0
ga_forecast$drisk[ga_forecast$Region != "gbr" & ga_forecast$value > 0.05 & ga_forecast$value <= 0.10] <- 1
ga_forecast$drisk[ga_forecast$Region != "gbr" & ga_forecast$value > 0.10 & ga_forecast$value <= 0.15] <- 2
ga_forecast$drisk[ga_forecast$Region != "gbr" & ga_forecast$value > 0.15 & ga_forecast$value <= 0.25] <- 3
ga_forecast$drisk[ga_forecast$Region != "gbr" & ga_forecast$value > 0.25] <- 4

# save
save(ga_forecast, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ga_forecast.RData")

# ws forecasts
ws_forecast <- aggregate_predictions(ws_outputs)

# add alert levels
# WS GBR
ws_forecast$drisk <- NA
ws_forecast$drisk[ws_forecast$Region == "gbr" & ws_forecast$value >= 0 & ws_forecast$value <= 1] <- 0
ws_forecast$drisk[ws_forecast$Region == "gbr" & ws_forecast$value > 1 & ws_forecast$value <= 5] <- 1
ws_forecast$drisk[ws_forecast$Region == "gbr" & ws_forecast$value > 5 & ws_forecast$value <= 10] <- 2
ws_forecast$drisk[ws_forecast$Region == "gbr" & ws_forecast$value > 10 & ws_forecast$value <= 20] <- 3
ws_forecast$drisk[ws_forecast$Region == "gbr" & ws_forecast$value > 20] <- 4

# WS Pacific
ws_forecast$drisk[ws_forecast$Region != "gbr" & ws_forecast$value >= 0 & ws_forecast$value <= 0.01] <- 0
ws_forecast$drisk[ws_forecast$Region != "gbr" & ws_forecast$value > 0.01 & ws_forecast$value <= 0.05] <- 1
ws_forecast$drisk[ws_forecast$Region != "gbr" & ws_forecast$value > 0.05 & ws_forecast$value <= 0.10] <- 2
ws_forecast$drisk[ws_forecast$Region != "gbr" & ws_forecast$value > 0.10 & ws_forecast$value <= 0.15] <- 3
ws_forecast$drisk[ws_forecast$Region != "gbr" & ws_forecast$value > 0.15] <- 4

# save
save(ws_forecast, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ws_forecast.RData")
