library(randomForest)

plot_var_imp <- function(mod_obj, mod_name, fig_dir){
  # create filepath
  filePath_scaled <- paste0(fig_dir, 
                            mod_name, 
                            "_scaled.pdf")
  # save pdf file with dimensions
  pdf(file = filePath_scaled, 
      height = 6, 
      width = 12)
  
  # create plot
  varImpPlot(mod_obj, 
             scale = TRUE, 
             main = mod_name)
  
  # turn off plotting device
  dev.off()
}
