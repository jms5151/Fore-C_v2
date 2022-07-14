# Load files
validation_files <- list.files('../compiled_data/survey_data/validation_data/', full.names = TRUE)
validation_files <- validation_files[grep('.RData', validation_files)]
lapply(validation_files, load, .GlobalEnv)

# load libraries
library(ggplot2)
library(tidyverse)
library(cowplot)

# V3 GA GBR scatterplot --------------------------------------
ga_gbr_plt <- ggplot(v3_ga_gbr, aes(x = Observed, y = Predicted)) +
  geom_errorbar(aes(ymin = V3_Q50, ymax = V3_Q90), color = '#00AFBB') + ##003333
  geom_point(alpha = 0.6, color = '#00AFBB') +
  theme_bw() +
  xlim(0, 80) +
  ylim(0, 80) +
  ylab('Predicted abundance') +
  xlab('Observed abundance') +
  theme(legend.position = 'none')

# V3 GA Pacific scatterplot ---------------------------------
ga_pac_plt <- ggplot(v3_ga_pac, aes(x = Observed, y = Predicted)) +
  geom_errorbar(aes(ymin = V3_Q50, ymax = V3_Q90), color = '#00AFBB') +
  geom_point(alpha = 0.6, color = '#00AFBB') +
  theme_bw() +
  xlim(0, 1) +
  ylim(0, 1) +
  ylab('Predicted prevalence') +
  xlab('Observed prevalence')

# V2 & V3 WS GBR scatterplot ---------------------------------
# adjust for second y-axis (divide by two when specifying values on plot)
v2_ws_gbr$Predicted <- v2_ws_gbr$Predicted*2
ws_gbr_nowcast <- bind_rows(v2_ws_gbr, v3_ws_gbr)
ylimMax <- ceiling(max(ws_gbr_nowcast$V3_Q90, na.rm = T))

ws_gbr_plt <- ggplot(ws_gbr_nowcast, aes(x = Observed, y = Predicted, col = Version)) +
  geom_errorbar(aes(ymin = V3_Q50, ymax = V3_Q90), col = '#00AFBB', width=0) + # #00AFBB
  geom_point(alpha = 0.6) +
  theme_bw() +
  scale_color_manual(values = c('#E7B800', '#00AFBB')) + # , "#FC4E07"
  scale_y_continuous(
    # Features of the first axis
    name = 'Predicted abundance',
    # Add a second axis and specify its features
    sec.axis = sec_axis( trans=~./2, name = 'Predicted risk level')
  ) +
  xlab('Observed abundance') +
  xlim(0, ylimMax) +
  theme(legend.position = 'none') +
  theme(legend.position = c(0.9, 0.8),
        legend.background = element_rect(fill = "white", color = "black")
  )

# V2 & V3 WS Pacific scatterplot ----------------------------
# adjust for second y-axis (multiply by max value when specifying values on plot)
v2predMax <- max(v2_ws_pac$Predicted)
v2_ws_pac$Predicted <- v2_ws_pac$Predicted/v2predMax
ws_pac_nowcast <- bind_rows(v2_ws_pac, v3_ws_pac)

ws_pac_plt <- ggplot(ws_pac_nowcast, aes(x = Observed, y = Predicted, col = Version)) +
  geom_errorbar(aes(ymin = V3_Q50, ymax = V3_Q90), col = '#00AFBB') +
  geom_point(alpha = 0.6) +
  theme_bw() +
  scale_color_manual(values = c('#E7B800', '#00AFBB')) +# , "#FC4E07"
  scale_y_continuous(
    # Features of the first axis
    name = 'Predicted prevalence',
    # Add a second axis and specify its features
    sec.axis = sec_axis( trans=~.*v2predMax, name = 'Predicted risk level')
  ) +
  xlab('Observed prevalence') +
  theme(legend.position = 'none') 


# combine for plots & add labels
p <- plot_grid(
  ws_gbr_plt
  , ga_gbr_plt
  , ws_pac_plt 
  , ga_pac_plt # +
  , labels = c('A', 'B', 'C', 'D')
  , label_size = 12
  )

# set margins and add text
p2 <- p + 
  annotate("text", x = 0.25, y = 1.04, size = 7, label = 'White syndromes') +
  annotate("text", x = 0.75, y = 1.04, size = 7, label = 'Growth anomalies') +
  annotate("text", x = 0, y = 0.78, size = 7, label = 'Great Barrier Reef\n', angle = 90) +
  annotate("text", x = 0, y = 0.28, size = 7, label = 'U.S. Pacific\n', angle = 90) +
  theme(plot.margin = unit(c(1, 0.5, 0.5, 1), "cm")) 

# p2

# save plot
ggsave(filename = '../../Figures/paper_figures/final/v2_vs_v3.pdf', height = 7, width = 10,
       plot = p2)

