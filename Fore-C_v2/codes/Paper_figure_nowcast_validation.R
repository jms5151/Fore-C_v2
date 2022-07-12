# Load files
validation_files <- list.files('../compiled_data/survey_data/validation_data/v3_ga_gbr.RData')
validation_files <- validation_files[grep('.RData', validation_files)]
lapply(validation_files, load, .GlobalEnv)

# V3 GA GBR scatterplot --------------------------------------
ga_gbr_plt <- ggplot(v3_ga_gbr, aes(x = Observed, y = Predicted)) +
  geom_errorbar(aes(ymin = V3_Q50, ymax = V3_Q90)) +
  geom_point(alpha = 0.6) +
  theme_bw() +
  xlim(0, 80) +
  ylim(0, 80) +
  ylab('Predicted abundance') +
  xlab('Observed abundance')


# V3 GA Pacific scatterplot ---------------------------------
ga_pac_plt <- ggplot(v3_ga_pac, aes(x = Observed, y = Predicted)) +
  geom_errorbar(aes(ymin = V3_Q50, ymax = V3_Q90)) +
  geom_point(alpha = 0.6) +
  theme_bw() +
  ylab('Predicted prevalence') +
  xlab('Observed prevalence')

# V2 & V3 WS GBR scatterplot ---------------------------------
v2_ws_gbr$Predicted <- v2_ws_gbr$Predicted*2
ws_gbr_nowcast <- bind_rows(v2_ws_gbr, v3_ws_gbr)

ws_gbr_plt <- ggplot(ws_gbr_nowcast, aes(x = Observed, y = Predicted, col = Version)) +
  geom_errorbar(aes(ymin = V3_Q50, ymax = V3_Q90), col = '#00AFBB', width=0) +
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
  theme(legend.position = c(0.10, 0.85),
        legend.background = element_rect(fill = "white", color = "black"))

# V2 & V3 WS Pacific scatterplot ----------------------------
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

# combine all together for barplots ----------------------------------------
all_nowcast_predications <- bind_rows(
  ws_pac_nowcast
  , ws_gbr_nowcast
  , V3_ga_pac
  , V3_ga_gbr
)

# I think something might be wrong here, maybe don't use boxplots because it's 
# really hard to compare with prevalence
all_nowcast_predications$Difference <- all_nowcast_predications$Predicted - all_nowcast_predications$Observed
maxValue <- max(abs(all_nowcast_predications$Difference[all_nowcast_predications$Region == 'GBR']))
all_nowcast_predications$Difference <- ifelse(all_nowcast_predications$Region == 'Pacific', all_nowcast_predications$Difference*maxValue, all_nowcast_predications$Difference)
all_nowcast_predications$dv <- paste0(all_nowcast_predications$Disease, '\n', all_nowcast_predications$Version)

nowcast_boxplots <- ggplot(all_nowcast_predications, aes(x = dv, y = Difference, fill = dv, col = dv)) +
  geom_boxplot() + # outlier.alpha = 0
  facet_grid(~Region, scales = 'free') +
  theme_bw() +
  scale_y_continuous(
    # Features of the first axis
    name = 'Difference (abunance)',
    # Add a second axis and specify its features
    sec.axis = sec_axis( trans=~./maxValue, name = 'Difference (prevalence)')
  ) +
  xlab('') +
  scale_fill_manual(values = c('black', '#00AFBB', '#E7B800')) +
  scale_color_manual(values = c('black', 'cyan2', '#E7B800')) +
  theme(legend.position = 'none') 

# library(cowplot)
# plot_grid(ws_gbr_plt, ws_pac_plt, ga_gbr_plt, ga_pac_plt, nowcast_boxplots, labels = c('A', 'B', 'C', 'D', 'E'), label_size = 12)
# 
# ggdraw() +
#   draw_plot(ws_gbr_plt, x = 0, y = 1/5, width = 0.5, height = 1/5) +
#   draw_plot(ws_pac_plt, x = 0.5, y = 1/5, width = 0.5, height = 1/5) +
#   draw_plot(ga_gbr_plt, x = 0, y = 1/5, width = 0.5, height = 1/5) +
#   draw_plot(ga_pac_plt, x = 0.5, y = 1/5, width = 0.5, height = 1/5) +
#   draw_plot(nowcast_boxplots, x = 0, y = 1/5, width = 1, height = 1/5) #+
# 
# 
# library(ggpubr)
# ggarrange(ggarrange(ws_gbr_plt, ws_pac_plt, ga_gbr_plt, ga_pac_plt
#                     , ncol = 2#, 
#                     # labels = c("B", "C")
#                     ), # Second row with box and dot plots
#           nowcast_boxplots,                                                 # First row with scatter plot
#           nrow = 3#, 
#           # labels = "A"                                        # Labels of the scatter plot
# ) 

library(gridExtra)
grid.arrange(arrangeGrob(ws_gbr_plt, ws_pac_plt, ga_gbr_plt, ga_pac_plt,
                         heights = c(1/3, 1/3)),
             ncol = 1,
             nowcast_boxplots
)

