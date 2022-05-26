library(tidyverse)
library(plotly)

# load data
load("../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ga_forecast.RData")
load("../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/ws_forecast.RData")

# figure out which date to use
nowcast_date_indexes <- which(ga_forecast$Date == max(ga_forecast$Date[ga_forecast$type == "nowcast"]))
current_nowcast_date <- ga_forecast[nowcast_date_indexes[1], "Date"][[1]]

# summary disease data to show the max value for each ID within
# the forecast period
# perhaps use the most recent nowcast instead
ga <- ga_forecast %>%
  filter(Date == current_nowcast_date) %>%
  group_by(ID, Region) %>%
  summarize("Growth anomalies" = max(drisk)) 

ws <- ws_forecast %>%
  filter(Date == current_nowcast_date) %>%
  group_by(ID, Region) %>%
  summarize("White syndromes" = max(drisk))

# combine
dz <- ga %>% 
  left_join(ws) %>%
  gather(key = "Disease", 
         "drisk", 
         "Growth anomalies":"White syndromes") %>%
  filter(!is.na(drisk))

# update region
dz$Region[dz$Region == "wake" | dz$Region == "johnston"] <- "prias"

# calculate total number of pixels per region
ntotals <- dz %>%
  filter(Disease == "Growth anomalies") %>% # doesn't matter which disease we use here, they use the same grid 
  group_by(Region) %>%
  summarize("ntotal" = length(Region))

# summarize by stress level
# this may need adjustment when including all regions
# because GBR is 0-Inf and everywhere else is 0-1
gauge_data <- dz %>%
  left_join(ntotals) %>%
  group_by(Disease, Region) %>%
  summarize(No_stress = sum(drisk == 0)/unique(ntotal),
            Watch = sum(drisk == 1)/unique(ntotal),
            Warning = sum(drisk == 2)/unique(ntotal),
            Alert_Level_1 = sum(drisk == 3)/unique(ntotal),
            Alert_Level_2 = sum(drisk == 4)/unique(ntotal)
            ) %>%
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

# subset and save 
# GBR - GA
gauge_gbr_ga <- subset(gauge_data, Disease == "Growth anomalies" & Region == "gbr")

# GBR - WS
gauge_gbr_ws <- subset(gauge_data, Disease == "White syndromes" & Region == "gbr")

# Hawaii - GA
gauge_hi_ga <- subset(gauge_data, Disease == "Growth anomalies" & Region == "hawaii")

# Hawaii - WS
gauge_hi_ws <- subset(gauge_data, Disease == "White syndromes" & Region == "hawaii")

# PRIAs - GA
gauge_prias_ga <- subset(gauge_data, Disease == "Growth anomalies" & Region == "prias")

# PRIAs - WS
gauge_prias_ws <- subset(gauge_data, Disease == "White syndromes" & Region == "prias")

# Samoas - GA
gauge_samoas_ga <- subset(gauge_data, Disease == "Growth anomalies" & Region == "samoas")

# Samoas - WS
gauge_samoas_ws <- subset(gauge_data, Disease == "White syndromes" & Region == "samoas")

# Guam/CNMI - GA
gauge_cnmi_ga <- subset(gauge_data, Disease == "Growth anomalies" & Region == "guam_cnmi")

# Guam/CNMI - WS
gauge_cnmi_ws <- subset(gauge_data, Disease == "White syndromes" & Region == "guam_cnmi")


# create plots -----------------------------------------------------------------
individual_gauges <- function(df){
  plot_ly(df,
          x = ~Value,
          y = ~Disease,
          type = 'bar',
          # text = ~N,
          color = ~name,
          marker = list(color = ~colors,
                        line = list(color = I("black"),
                                    width = 1.5)),
          hovertemplate = '%{x:.2p} of reef pixels <extra></extra>'
  ) %>%
    layout(yaxis = list(title = '',
                        showticklabels = FALSE,
                        tickformat = ""),
           xaxis = list(title = '',
                        showticklabels = FALSE,
                        tickformat = "",
                        showgrid = F,
                        zeroline = FALSE),
           barmode = 'stack',
           showlegend = FALSE,
           margin = list(
             l = 0,
             r = 0,
             b = 0,
             t = 0
           )
    )
}

gauge_ga_samoas <- individual_gauges(gauge_samoas_ga)
gauge_ws_samoas <- individual_gauges(gauge_samoas_ws)

gauge_ga_cnmi <- individual_gauges(gauge_cnmi_ga)
gauge_ws_cnmi <- individual_gauges(gauge_cnmi_ws) 

gauge_ga_gbr <- individual_gauges(gauge_gbr_ga)
gauge_ws_gbr <- individual_gauges(gauge_gbr_ws)

gauge_ga_hi <- individual_gauges(gauge_hi_ga)
gauge_ws_hi <- individual_gauges(gauge_hi_ws)

gauge_ga_prias <- individual_gauges(gauge_prias_ga)
gauge_ws_prias <- individual_gauges(gauge_prias_ws) %>%
  layout(
    xaxis = list(
      title = 'Percent of pixels per risk category',
      showticklabels = TRUE,
      tickformat = ".0%",
      showgrid = FALSE,
      zeroline = FALSE,
      font = list(
        size = 11,
        family = "Arial"
      )
    )
  )


xlab_placement = 0
ylab_placement = 0.9
fontSize = 11

aList <- list(  
  xanchor = 'left',
  x = xlab_placement,
  y = ylab_placement,
  font = list(size = fontSize,
              family = "Arial"
  ),
  showarrow = F
)

gaugePlots <- subplot(
  gauge_ga_samoas %>%
    layout(
      annotations = c(
        aList, 
        text = "American Samoa - growth anomalies"
      )
    ),
  gauge_ws_samoas %>%
    layout(
      annotations = c(
        aList,
        text = "American Samoa - white syndromes"
      )
    ),
  gauge_ws_cnmi %>%
    layout(
      annotations = c(
        aList,
        text = "Guam/CNMI - white syndromes"
      )
    ),
  gauge_ga_cnmi %>%
    layout(
      annotations = c(
        aList,
        text = "Guam/CNMI - growth anomalies"
      )
    ),
  gauge_ga_gbr %>%
    layout(
      annotations = c(
        aList,
        text = "Great Barrier Reef - growth anomalies"
      )
    ),
  gauge_ws_gbr %>%
    layout(
      annotations = c(
        aList,
        text = "Great Barrier Reef - white syndromes"
      )
    ),
  gauge_ga_hi %>%
    layout(
      annotations = c(
        aList,
        text = "Hawaii - growth anomalies"
      )
    ),
  gauge_ws_hi %>%
    layout(
      annotations = c(
        aList,
        text = "Hawaii - white syndromes"
      )
    ),
  gauge_ga_prias %>%
    layout(
      annotations = c(
        aList,
        text = "PRIAs - growth anomalies"
      )
    ),
  gauge_ws_prias %>%
    layout(
      annotations = c(
        aList,
        text = "PRIAs - white syndromes"
      )
    ),
  nrows = 10,
  margin = 0.01,
  heights = rep(0.1, 10)
  , titleX = TRUE
  # , shareX = TRUE
  ) %>% 
  config(
    displayModeBar = F
  ) %>%
  layout(
    margin = list(
      t = 0,
      b = 60, 
      l = 0,
      r = 0
      )
  ) 

save(gaugePlots, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Forecasts/gaugePlots.RData")
