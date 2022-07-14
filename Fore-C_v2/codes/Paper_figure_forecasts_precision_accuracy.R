# load data
load('../compiled_data/survey_data/validation_data/v3_forecasts_aggregated.RData')

# load libraries
library(ggplot2)
library(cowplot)

# may want to end Prediction precision so high numbers = more precise
# for the pacific, this is just 1 - prediction_precision
# not sure best way to do this for the gbr, since risk = abundance, with predictions [0, inf)

# format group name labels 
forec_forecasts_agg$groupLabels <- paste(forec_forecasts_agg$Disease, forec_forecasts_agg$Region, sep = ', ')
forec_forecasts_agg$groupLabels <- gsub('GBR', 'Great Barrier Reef', forec_forecasts_agg$groupLabels)
forec_forecasts_agg$groupLabels <- gsub('Pacific', 'U.S. Pacific', forec_forecasts_agg$groupLabels)

# Accuracy plots 
accuracy_plot <- ggplot(forec_forecasts_agg, aes(x = Lead_time, y = Prediction_accuracy, group = Lead_time, fill = groupLabels)) +
  geom_boxplot() +
  facet_wrap(~groupLabels, scales = 'free', ncol = 1) + 
  # set unique ylimits by facet, with equal below and above one
  scale_y_continuous(limits = function(x){c(-max(x, 1), max(x, 1))}) +
  theme_bw() +
  theme(
    legend.position = 'none'
    # , plot.title = element_text(size = 12, hjust = 0.5, face = 'bold')
    , panel.spacing = unit(2, "lines")
    , strip.text.x = element_blank()
  ) +
  ggtitle('') + #Accuracy
  xlab('') +
  ylab('Prediction accuracy\n(75th percentile prediction - observed)\n') +
  scale_x_reverse(labels = as.character(forec_forecasts_agg$Lead_time), breaks = forec_forecasts_agg$Lead_time) +
  geom_hline(yintercept = 0, linetype = 'dashed')

# Precision plots 
precision_plot <- ggplot(forec_forecasts_agg, aes(x = Lead_time, y = Prediction_precision, group = Lead_time, fill = groupLabels)) +
  geom_boxplot() +
  facet_wrap(~groupLabels, scales = 'free', ncol = 1) + 
  # set unique ylimits and position axis on right side of plot
  scale_y_continuous(position = 'right', limits = function(x){c(0, max(x, 1))}) +
  theme_bw() +
  theme(
    legend.position = 'none'
    # , plot.title = element_text(size = 12, hjust = 0.5, face = 'bold')
    , panel.spacing = unit(2, "lines")
    , strip.text.x = element_blank()
  ) +
  ggtitle('') + #Precision
  xlab('') +
  ylab('Prediction precision\n(90th - 50th percentile predictions)\n') +
  scale_x_reverse(labels = as.character(forec_forecasts_agg$Lead_time), breaks = forec_forecasts_agg$Lead_time) +
  geom_hline(yintercept = 0, linetype = 'dashed')

# combine and annotate plots
ap_plot <- plot_grid(accuracy_plot, precision_plot, ncol = 2)

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


