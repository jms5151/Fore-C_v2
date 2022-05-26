# plot residuals ---------------------------------------------------------------
library(quantregForest)

resid_plots <- function(mod, newdata, title, yVar){
  # predict
  x <- predict(
    mod
    , what = 0.75#c(0.50, 0.75, 0.90)
    , newdata = newdata
  )
  # plot
  pdf(paste0('../../Figures/Quantile_forests/residuals/', title, '.pdf'), height = 5, width = 8)
  xdiff <- newdata[, yVar] - x
  plot(newdata[, yVar], xdiff, pch = 16, ylab = 'Residuals (observed - predicted)', xlab = 'Observed', main = title)
  abline(h = 0)
  dev.off()
}
