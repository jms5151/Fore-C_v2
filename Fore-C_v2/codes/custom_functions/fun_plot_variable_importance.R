library(randomForest)

plot_var_imp <- function(mod_obj, mod_name, fig_dir, h, w){
  # create filepath
  filePath_scaled <- paste0(fig_dir, 
                            mod_name, 
                            "_scaled.pdf")
  # save pdf file with dimensions
  pdf(file = filePath_scaled, 
      height = 8, #6
      width = 8)#12
  
  # create plot
  varImpPlot(mod_obj
             , scale = TRUE
             , main = mod_name
             , pch = 16
             , cex = 1.2
             , pt.cex = 1.5
             , type = 1 # variable importance, 2 = node impurity
             )
  # turn off plotting device
  dev.off()
}

var_imp_plot2 <- function(mod_obj, mod_name, fig_dir){
  
  filePath_scaled <- paste0(fig_dir, 
                            mod_name, 
                            ".pdf")
  # save pdf file with dimensions
  pdf(file = filePath_scaled, 
      height = 6, 
      width = 12)
  
  # create plot
  impToPlot <- importance(mod_obj, scale = FALSE)
  dotchart(
    sort(impToPlot[,1])
    , main = mod_name
    , xlim=c(0,1)
    , cex = 1.2
    , xlab = 'Variable importance\n(% increase MSE)'
    , pch = 16)
  
  # turn off plotting device
  dev.off()
  
}
