# custom function for creating synthetic datasets
library(smotefamily)

create_smote_df <- function(df, dz_vars, responseVar, threshold){
  df$Health_status <- ifelse((df[, responseVar] <= threshold), 0, 1)
  x <- df[, c("Health_status", dz_vars)]
  x <- x[complete.cases(x),]
  dz_smote = SMOTE(x,
                   target = x$Health_status,
                   K = 3,
                   dup_size = 3)
  as.data.frame(dz_smote$data)
}

