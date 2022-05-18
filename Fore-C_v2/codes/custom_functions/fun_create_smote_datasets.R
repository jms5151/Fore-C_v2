# custom function for creating synthetic datasets
library(tidyverse)
library(smotefamily)

create_smote_df <- function(df, yVar, threshold){
  df <- df %>% select(-c(Date))
  df$Health_status <- ifelse((df[, yVar] <= threshold), 0, 1)
  sum(df$Health_status == 0) - sum(df$Health_status != 0)
  dz_smote = SMOTE(
    df
    , target = df$Health_status
    , K = 3
    )
  # format
  dz_smote <- as.data.frame(dz_smote$data)
  dz_smote$Month <- as.integer(round(dz_smote$Month))
  # sum(dz_smote$Health_status == 0)
  # sum(dz_smote$Health_status == 1)
  dz_smote <- dz_smote %>% select(-c(Health_status, class))
  dz_smote
}

