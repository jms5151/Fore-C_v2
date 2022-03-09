# Create placeholder plots for Shiny app ---------------------------------------
library(plotly)

scenarios_placeholder_plot <- plot_ly(
  x = "",
  y = 0, 
  type = "bar"
  ) %>%
  layout(
    xaxis = list(
      showgrid = F,
      title = ""
    ), 
    yaxis = list(
      showline = T,
      showgrid = F,
      range = c(-100, 100),
      title = "Change in disease risk<br>(from current conditions)"
    ),
    font = list(size = 14),
    showlegend = FALSE
    ) 

save(scenarios_placeholder_plot, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Static_data/scenarios_placeholder_plot.Rds")
