# load libraries
library(data.table)
library(quantregForest)
library(ggplot2)
library(ggpubr)
library(ggExtra)

# function to run variable selection ----------------------
var_selection <- function(x_train, y_train, x_test, y_test){
  qtrain <- quantregForest(x_train, y_train, importance = TRUE)
  
  quant <- predict(qtrain,
                   what = c(0.05, 0.75, 0.95),
                   newdata = x_test)
  
  list((sort(qtrain$importance[,1])), (summary(lm(quant[,2] ~ y_test))))
}

# function to update variables in selection process -------
updated_vars <- function(x, namesToKeep){
  x2 <- x[!grepl(namesToKeep, names(x))] 
  namesToAdd <- unlist(strsplit(namesToKeep, split='\\|'))
  c(namesToAdd, names(x2[2:length(x2)])) # remove variable of lowest importance
}

# model selection function --------------------------------
mod_select <- function(df, dz_vars, responseVar, varToKeep, DFfileName){
  create_data_frame(DFfileName, c("AdjR2", "Num_vars", "Model_variables"))
  tt_data <- subset_and_split_sample(df, dz_vars, responseVar)
  while(length(dz_vars) > 3){
    x <- var_selection(tt_data[[1]], 
                       unlist(tt_data[[2]]), 
                       tt_data[[3]], 
                       unlist(tt_data[[4]])
    )
    
    tmp_df <- data.frame(x[[2]]$adj.r.squared, length(dz_vars), toString(names(x[[1]])))
    write.table(tmp_df, 
                file=DFfileName, 
                row.names = F, 
                sep = ",", 
                col.names = !file.exists(DFfileName), 
                append = T)
    
    dz_vars <- updated_vars(x[[1]], varToKeep)
    tt_data <- update_sample_split_vars(tt_data, dz_vars)
  }
}

# plot results ----------------------------------------------
plot_with_marginal_distribution <- function(y_obs, predictions_list, plotTitle){
  dfx <- data.frame("Y_obs" = y_obs,
                    "Y_pred" = predictions_list[,2],
                    "Y_05" = predictions_list[,1],
                    "Y_95" = predictions_list[,3])
  
  name2 <- gsub(" ", "_", plotTitle)

  if(max(dfx$Y_obs) <= 1){
    maxLim <- 1.1
    textY1 <- 1.05
    textY2 <- 1
  } else {
    maxLim <- max(dfx$Y_obs, dfx$Y_95) + 10
    textY1 <- max(dfx$Y_obs, dfx$Y_95) + 5
    textY2 <- max(dfx$Y_obs, dfx$Y_95) 
  }
  
  p <- ggplot(data = dfx, aes(x = Y_obs, y = Y_pred)) +
    geom_point(alpha = 0.3, size = 2) +
    geom_errorbar(aes(ymin = Y_05, ymax = Y_95), width = 0.01) +
    theme(legend.position = "none") +
    ylim(0, maxLim) +
    xlim(0, maxLim) +
    theme_classic() +
    theme(text = element_text(size = 14)) +
    ylab("Predicted") +
    xlab("Observed") +
    geom_abline(intercept = 0, slope = 1) +
    ggtitle(paste0("\n", plotTitle, "\ndata validation")) + 
    annotate("text", 
             x = c(0,0),
             y = c(textY1, textY2),
             hjust = 0,
             label = c(paste0("Adj R^2 = ",
                              round(summary(lm(dfx$Y_pred ~ dfx$Y_obs))$adj.r.squared, 2)),
                       paste0("N = ", nrow(dfx))
             )
    )
  ggExtra::ggMarginal(p, type = "histogram")
}

# select covariates from best model ----------------------------
select_best_mod_covars <- function(df){
  best_mod_index <- which(df$AdjR2 == max(df$AdjR2))
  df$Model_variables[best_mod_index]
}

select_best_parsimonious_mod_covars <- function(df){
  parsimonious_mod <- subset(df, AdjR2 >= max(df$AdjR2)-0.02)
  parsimoniousR2 <- parsimonious_mod$AdjR2[parsimonious_mod$Num_vars == min(parsimonious_mod$Num_vars)]
  best_mod_index <- which(df$AdjR2 == parsimoniousR2)
  df$Model_variables[best_mod_index]
}

# subset out of sample data -----------------------------------
oos_subset <- function(OOSdata, responseVar, dz_vars){
  LO <- OOSdata[, c(responseVar, dz_vars)]
  LO <- LO[complete.cases(LO), ]
  LO_y <- LO[, responseVar]
  LO <- LO[, -1]
  list(LO, LO_y)
}