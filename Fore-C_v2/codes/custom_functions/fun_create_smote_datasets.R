# custom function for creating synthetic datasets
library(smotefamily)

create_smote_df <- function(df, responseVar, threshold){
  df$Health_status <- ifelse((df[, responseVar] <= threshold), 0, 1)
  dz_smote = SMOTE(x,
                   target = x$Health_status,
                   K = 3,
                   dup_size = 3)
  as.data.frame(dz_smote$data)
}

