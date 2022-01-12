library(tidyverse)

# load data
load("../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ga_forecast.RData")
load("../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ws_forecast.RData")

# summary disease data to show the max value for each ID within
# the forecast period
ga <- ga_forecast %>%
  group_by(ID, Region) %>%
  summarize("Growth anomalies" = max(value)) 

ws <- ws_forecast %>%
  group_by(ID, Region) %>%
  summarize("White syndromes" = max(value))

# combine
dz <- ga %>% 
  left_join(ws) %>%
  gather(key = "Disease", 
         "MaxValue", 
         "Growth anomalies":"White syndromes")

# calculate total number of pixels per region
ntotals <- ga %>% # doesn't matter which disease we use here, they use the same grid 
  group_by(Region) %>%
  summarize("ntotal" = length(Region))

# summarize by stress level
# this may need adjustment when including all regions
# because GBR is 0-Inf and everywhere else is 0-1
gauge_data <- dz %>%
  left_join(ntotals) %>%
  group_by(Disease, Region) %>%
  summarize(No_stress = sum(MaxValue == 0)/unique(ntotal),
            Watch = sum(MaxValue > 0 & MaxValue <= 1)/unique(ntotal),
            Warning = sum(MaxValue > 1 & MaxValue <= 5)/unique(ntotal),
            Alert_Level_1 = sum(MaxValue > 5 & MaxValue <= 10)/unique(ntotal),
            Alert_Level_2 = sum(MaxValue > 10)/unique(ntotal)) %>%
  gather(key = "Alert_Level", "Value", No_stress:Alert_Level_2)


# format colors
gauge_data$colors <- NA
gauge_data$colors[gauge_data$Alert_Level == "No_stress"] <-  "#CCFFFF"
gauge_data$colors[gauge_data$Alert_Level == "Watch"] <-  "#FFEF00"
gauge_data$colors[gauge_data$Alert_Level == "Warning"] <-  "#FFB300"
gauge_data$colors[gauge_data$Alert_Level == "Alert_Level_1"] <-  "#EB1F08"
gauge_data$colors[gauge_data$Alert_Level == "Alert_Level_2"] <-  "#8D1002"

# format alert names and make ordered factor 
gauge_data$name <- gsub("_", " ", gauge_data$Alert_Level)

gauge_data$name <- factor(gauge_data$name, 
                  levels = c("No stress",
                             "Watch",
                             "Warning",
                             "Alert Level 1",
                             "Alert Level 2"))

# save data
save(gauge_data, 
     file = "../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/gauge_data.RData")
