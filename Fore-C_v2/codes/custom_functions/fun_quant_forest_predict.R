# prediction function
library(quantregForest)

# forecast predictions
qf_predict <- function(df, regionGBRtrue, family, final_mod, name, save_dir, fileName2){
  # subset data by region and variables in model
  if(regionGBRtrue == TRUE){
    df2 <- subset(df, Region == "gbr")
  } else {
    col_size <- paste0("Median_colony_size_", family)
    df$Median_colony_size <- pull(df, col_size)
    cv_size <- paste0("CV_colony_size_", family)
    df$CV_colony_size <- pull(df, cv_size)
    df2 <- subset(df, Region != "gbr")
  }
  id_vars <- c("ID", "Latitude", "Longitude", "Region", "Date", "ensemble", "type")
  list_vars <- names(final_mod$forest$ncat)
  df2 <- df2[, c(id_vars, list_vars)]
  df2 <- na.omit(df2)
  xx <- as.data.frame(df2)
  # predict
  xpredict <- predict(final_mod,
               quantiles = c(0.50, 0.75, 0.95),
               newdata = df2
               )
  x2 <- cbind(df2[,id_vars]
              , "Lwr" = xpredict[,1]
              , "value" = xpredict[,2]
              , "Upr" = xpredict[,3]
              )
  dz_final <- as.data.frame(x2)
  save(dz_final, file = paste0(save_dir, name, "_", fileName2))
}


# scenarios predictions
qf_predict_scenarios <- function(df, regionGBRtrue, family, final_mod){
  # subset data by region and variables in model
  if(regionGBRtrue == TRUE){
    df2 <- subset(df, Region == "gbr")
  } else {
    col_size <- paste0("Median_colony_size_", family)
    df$Median_colony_size <- pull(df, col_size)
    cv_size <- paste0("CV_colony_size_", family)
    df$CV_colony_size <- pull(df, cv_size)
    df2 <- subset(df, Region != "gbr")
  }
  id_vars <- c("ID", "Latitude", "Longitude", "Region", "Date", "value", "Response", "Response_level")
  list_vars <- names(final_mod$forest$ncat)
  df2 <- df2[, c(id_vars, list_vars)]
  df2 <- na.omit(df2)
  xx <- as.data.frame(df2)
  # predict
  xpredict <- predict(final_mod,
                      quantiles = c(0.50, 0.75, 0.95),
                      newdata = df2
  )
  x2 <- cbind(df2[,id_vars]
              , "LwrEstimate" = xpredict[,1]
              , "estimate" = xpredict[,2]
              , "UprEstimate" = xpredict[,3]
  )
  as.data.frame(x2)
}
