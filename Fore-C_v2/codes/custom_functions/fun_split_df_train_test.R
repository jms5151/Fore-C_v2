library(caTools)

## Haven't updated this function yet
# Prob want to save four files for each disease-region-threshold
split_train_test_dfs <- function(df){
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