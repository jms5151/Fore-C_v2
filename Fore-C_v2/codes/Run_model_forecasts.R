# Run forecasts using quantil regression models

source("./codes/custom_functions/fun_quant_forest_predict.R")

# best model results shown here:
# best_mods_summary <- read.csv("../model_selection_summary_results/parsimonious_best_models_by_disease_and_region.csv")

# open model objects
GA_GBR_Model <- readRDS("../model_objects/ga_gbr_parsimonious_best_smote_0.rds")
# GA_Pacific_Model <- readRDS("../model_objects/ga_pac_parsimonious_best_smote_5.rds")
WS_GBR_Model <- readRDS("../model_objects/ws_gbr_parsimonious_best_smote_0.rds")
# WS_PAC_Model <- readRDS("../model_objects/ws_pac_acr_parsimonious_best_smote_0.rds")

# set up directory filepaths
forecast_dir <- "../compiled_data/forecast_inputs/"
x <- list.files(forecast_dir)
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
  #            fileName2 = x[i])
  # # WS Pacific
  # qf_predict(df = df,
  #            regionGBRtrue = FALSE,
  #            family = "Acroporidae",
  #            final_mod = WS_Pacific_Model,
  #            name = "ws_pac",
  #            fileName2 = x[i])
  # GA GBR
  qf_predict(df = df,
             regionGBRtrue = TRUE,
             family = "",
             final_mod = GA_GBR_Model,
             name = "ga_gbr",
             fileName2 = x[i])
  # WS GBR
  qf_predict(df = df,
             regionGBRtrue = TRUE,
             family = "",
             final_mod = WS_GBR_Model,
             name = "ws_gbr",
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
save(ga_forecast, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ga_forecast.RData")

# ws forecasts
ws_forecast <- aggregate_predictions(ws_outputs)
save(ws_forecast, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ws_forecast.RData")
