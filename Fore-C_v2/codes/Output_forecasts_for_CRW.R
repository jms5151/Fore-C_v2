# create output for CRW
library(tidyverse)

# load data
load("../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ga_forecast.RData")
load("../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ws_forecast.RData")

# output directory
output_dir <- "../Compiled_data/output_for_crw/"

# figure out which dates to use
prediction_dates <- unique(ga_forecast$Date)

current_nowcast_date <- ga_forecast$Date[which(ga_forecast$Date == max(ga_forecast$Date[ga_forecast$type == "nowcast"]))[1]]
nowcast_id <- which(prediction_dates == current_nowcast_date)

one_month_forecast_date <- prediction_dates[nowcast_id + 4]
two_month_forecast_date <- prediction_dates[nowcast_id + 8]
three_month_forecast_date <- prediction_dates[nowcast_id + 12]

# summarize forecasts ----------------------------------------------------------
reef_forecast <- bind_rows(ga_forecast, ws_forecast) %>%
  filter(Date == current_nowcast_date | 
           Date == one_month_forecast_date |
           Date == two_month_forecast_date |
           Date == three_month_forecast_date) %>%
  mutate("Data_date" = Date) %>%
  group_by(ID,
           Latitude,
           Longitude,
           Region,
           Data_date) %>%
  summarize("Alert_Level" = max(drisk))

reef_forecast$Prediction <- NA 
reef_forecast$Prediction[reef_forecast$Data_date == current_nowcast_date] <- "Nowcast"
reef_forecast$Prediction[reef_forecast$Data_date == one_month_forecast_date] <- "4 week forecast"
reef_forecast$Prediction[reef_forecast$Data_date == two_month_forecast_date] <- "8 week forecast"
reef_forecast$Prediction[reef_forecast$Data_date == three_month_forecast_date] <- "12 week forecast"

regions <- unique(reef_forecast$Region)

for(i in regions){
  x <- subset(reef_forecast, Region == i)
  write.csv(x, paste0(output_dir, "forec_5km_nowcasts_and_forcasts_", i, ".csv"), row.names = F)
  
}

# time series ------------------------------------------------------------------
current_year <- format(Sys.time(), "%Y")
cutoff_date <- as.Date(paste0(current_year, "-01-01"), "%Y-%m-%d")

format_ts_predictions <- function(df, diseaseName, filter_date, nowcast_date_cutoff){
  x <- df %>%
    mutate("Data_date" = Date) %>%
    filter(Data_date >= filter_date) %>%
    group_by(Region,
             Data_date) %>%
    summarize(value = quantile(Lwr, 0.90, na.rm = T)
              , lwr = quantile(value, 0.90, na.rm = T)
              , upr = quantile(Upr, 0.90, na.rm = T)
              )
  colnames(x)[3:5] <- c(paste0(diseaseName, "50")
                        , paste0(diseaseName, "75")
                        , paste0(diseaseName, "90"))
  x$Prediction <- ifelse(x$Data_date <= nowcast_date_cutoff, "Nowcast", "Forecast")
  x
}

ga_ts <- format_ts_predictions(df = ga_forecast
                              , diseaseName = "GA"
                              , filter_date = cutoff_date
                              , nowcast_date_cutoff = current_nowcast_date)

ws_ts <- format_ts_predictions(df = ws_forecast
                               , diseaseName = "WS"
                               , filter_date = cutoff_date
                               , nowcast_date_cutoff = current_nowcast_date)


predictions_ts <- ga_ts %>% left_join(ws_ts)

# save
regions <- unique(predictions_ts$Region)

for(i in regions){
  x <- subset(predictions_ts, Region == i)
  ts_filepath <- paste0(output_dir, "forec_YTD_regional_disease_predictions_", i, ".csv")
  if(file.exists(ts_filepath) == TRUE){
    x_old <- read.csv(ts_filepath)
    x_old <- subset(x_old, Prediction == "Nowcast")
    x_old$Data_date <- as.Date(x_old$Data_date, "%Y-%m-%d")
    max_x_old_date <- max(x_old$Data_date[x_old$Prediction == "Nowcast"])
    x_new <- subset(x, Data_date > max_x_old_date)
    x <- bind_rows(x_old, x)
  }
  write.csv(x, ts_filepath, row.names = F)
}
