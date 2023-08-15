# Load files
validation_files <- list.files('../compiled_data/survey_data/validation_data/', full.names = TRUE)
validation_files <- validation_files[grep('.RData', validation_files)]
lapply(validation_files, load, .GlobalEnv)

# format
# v2_ws_gbr$Version <- 'V1'

# load libraries
library(ggplot2)
library(tidyverse)
library(egg)
library(ggpubr)

# V3 GA GBR scatterplot --------------------------------------
ga_gbr_plt <- ggplot(v3_ga_gbr, aes(x = Observed, y = Predicted)) +
  geom_abline(slope = 1, intercept = 0, color = 'grey') +
  geom_errorbar(aes(ymin = V3_Q50, ymax = V3_Q90), color = '#003333') + #
  geom_point(alpha = 0.6, color = '#003333') +
  theme_bw() +
  xlim(0, 80) +
  ylim(0, 80) +
  ylab('Predicted density') +
  xlab('Observed density') +
  ggtitle('Growth anomalies') +
  theme(plot.title = element_text(hjust = 0.5, size = 18)) +
  theme(legend.position = 'none') 

# V3 GA Pacific scatterplot ---------------------------------
v3_ga_pac[, c('Observed', 'V3_Q50', 'Predicted', 'V3_Q90')] <- v3_ga_pac[, c('Observed', 'V3_Q50', 'Predicted', 'V3_Q90')] * 100

ga_pac_plt <- ggplot(v3_ga_pac, aes(x = Observed, y = Predicted)) +
  geom_abline(slope = 1, intercept = 0, color = 'grey') +
  geom_errorbar(aes(ymin = V3_Q50, ymax = V3_Q90), color = '#003333') +
  geom_point(alpha = 0.6, color = '#003333') +
  theme_bw() +
  xlim(0, 100) +
  ylim(0, 100) +
  ylab('Predicted prevalence') +
  xlab('Observed prevalence') 

# V2 & V3 WS GBR scatterplot ---------------------------------
# adjust for second y-axis (divide by two when specifying values on plot)
v2_ws_gbr$Predicted <- v2_ws_gbr$Predicted*2
ws_gbr_nowcast <- bind_rows(v2_ws_gbr, v3_ws_gbr)
ylimMax <- ceiling(max(ws_gbr_nowcast$V3_Q90, na.rm = T))

ws_gbr_plt <- ggplot(ws_gbr_nowcast, aes(x = Observed, y = Predicted, col = Version)) +
  geom_abline(slope = 1, intercept = 0, color = 'grey') +
  geom_errorbar(aes(ymin = V3_Q50, ymax = V3_Q90), col = '#003333', width=0) + # #00AFBB
  geom_point(alpha = 0.6) +
  theme_bw() +
  scale_color_manual(values = c('orange', '#003333')) + # , "#FC4E07"
  scale_y_continuous(
    # Features of the first axis
    name = 'Predicted density',
    # Add a second axis and specify its features
    sec.axis = sec_axis( trans=~./2, name = 'Predicted risk level')
  ) +
  xlab('Observed density') +
  xlim(0, ylimMax) +
  ggtitle('White syndromes') +
  theme(plot.title = element_text(hjust = 0.5, size = 18)) +
  theme(legend.position = 'none') +
  theme(legend.position = c(0.9, 0.8),
        legend.background = element_rect(fill = "white", color = "black")
  )


# V2 & V3 WS Pacific scatterplot ----------------------------
# adjust for second y-axis (multiply by max value when specifying values on plot)
# v3_ws_pac[, c('Observed', 'V3_Q50', 'Predicted', 'V3_Q90')] <- v3_ws_pac[, c('Observed', 'V3_Q50', 'Predicted', 'V3_Q90')] * 100

v2predMax <- max(v2_ws_pac$Predicted)
v2_ws_pac$Predicted <- v2_ws_pac$Predicted/v2predMax
ws_pac_nowcast <- bind_rows(v2_ws_pac, v3_ws_pac)

ws_pac_plt <- ggplot(ws_pac_nowcast, aes(x = Observed, y = Predicted, col = Version)) +
  geom_abline(slope = 1, intercept = 0, color = 'grey') +
  geom_errorbar(aes(ymin = V3_Q50, ymax = V3_Q90), col = '#003333') +
  geom_point(alpha = 0.6) +
  theme_bw() +
  scale_color_manual(values = c('orange', '#003333')) +##E7B800 , "#FC4E07"
  scale_y_continuous(
    # Features of the first axis
    name = 'Predicted prevalence',
    labels = function(x) x * 100,
    # Add a second axis and specify its features
    sec.axis = sec_axis( trans=~.*v2predMax, name = 'Predicted risk level')
  ) +
  xlab('Observed prevalence') +
  theme(legend.position = 'none')


# combine for plots & add labels
p <- egg::ggarrange(  ws_gbr_plt
            , ga_gbr_plt
            , ws_pac_plt 
            , ga_pac_plt 
            , ncol = 2
            )

# silly but can't have two left arguments, so make long space
p2 <- annotate_figure(p, left = text_grob('U.S. Pacific                                 GBR', size = 18, rot = 90))

# save plot
ggsave(filename = '../../Figures/paper_figures/final/v2_vs_v3.pdf'
       , height = 7
       , width = 10
       , plot = p2)
