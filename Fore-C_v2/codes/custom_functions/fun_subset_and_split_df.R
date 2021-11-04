library(caTools)

subset_and_split_sample <- function(df, vars, yVar){
  # subset
  df <- df[, c(yVar, vars)]
  df <- df[complete.cases(df), ]
  # split sample
  sample = sample.split(unlist(df[,yVar]), SplitRatio = .75)
  train = subset(df, sample == TRUE)
  test  = subset(df, sample == FALSE)
  # format for quantile forest models
  x_train <- train[,-1]
  y_train <- train[,yVar]
  x_test <- test[,-1]
  y_test <- test[,yVar]
  # group output
  list(data.frame(x_train),
       data.frame(y_train),
       data.frame(x_test),
       data.frame(y_test)
  )
}

update_sample_split_vars <- function(orig_subset, newvars){
  x_train_update <- orig_subset[[1]]
  x_train_update <- x_train_update[, newvars]
  x_test_update <- orig_subset[[3]]
  x_test_update <- x_test_update[, newvars]
  orig_subset[[1]] <- x_train_update
  orig_subset[[3]] <- x_test_update
  orig_subset
}
