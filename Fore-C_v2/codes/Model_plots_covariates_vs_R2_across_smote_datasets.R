# plot number of covariates vs R2 for all smote datasets --------------

# list files
modresults <- list.files("../model_selection_results/", full.names = TRUE)

# separate files by model type
ga_gbr_results <- modresults[grep("ga_gbr", modresults)]
ga_pac_results <- modresults[grep("ga_pac", modresults)]
ws_gbr_results <- modresults[grep("ws_gbr", modresults)]
ws_pac_results <- modresults[grep("ws_pac", modresults)]

# combine as list
mod_results_list <- list(ga_gbr_results,
                         ga_pac_results,
                         ws_gbr_results,
                         ws_pac_results)


# create vector of list names
mod_results_names <- c("ga_gbr",
                       "ga_pac",
                       "ws_gbr",
                       "ws_pac")

# create filepath to save plots
save_file_dir <- "../../Figures/Quantile_forests/num_covars_vs_r2/"

# run loop to create multipanel plots of number of covariates vs R2
# for each smote data set within each disease type/region
for(i in 1:length(mod_results_list)){
  num_results <- length(mod_results_list[[i]])
  # this is not generic, but re-orders specific to these data files for plotting
  if(i == 1|i == 3){
    orderplots <- c(1,4,2,3)
  } else {
    orderplots <- c(1,5,2,3,4)
  }
  # save plot
  save_filepath <- paste0(save_file_dir, mod_results_names[i], "_covars_v_r2.pdf")
  pdf(save_filepath, width = 8.33, height = 5.97)
  par(mfrow = c(2, ceiling(num_results/2)))
  for(j in orderplots){
    # open file
    x <- read.csv(mod_results_list[[i]][j])
    # create new name for plot title
    name <- gsub("./model_selection_results/|with_predictors_|_count_|_prev_|results.csv", 
                 "", 
                 mod_results_list[[i]][j])
    # plot
    plot(x$Num_vars, 
         x$AdjR2, 
         pch = 16, 
         type = 'b',
         ylab = "Adj R2",
         xlab = "Number of covariates",
         main = name,
         yaxt = "n",
         ylim = c(0,1))
    axis(2, las = 2)  
  }
  dev.off()
}
