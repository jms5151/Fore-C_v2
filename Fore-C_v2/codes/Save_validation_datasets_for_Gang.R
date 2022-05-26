# load best models key
best_models_final <- read.csv('../model_selection_summary_results/parsimonious_best_models_by_disease_and_region.csv')

# directory paths
smote_dir <- '../compiled_data/survey_data/smote_datasets/'
save_dir <- '../compiled_data/survey_data/'

validation_df <- data.frame()

# save lat, lon, date for Gang to create retrospective forecasts
for(i in 1:nrow(best_models_final)){
  # format filenames for best models
  thsh <- ifelse(nchar(best_models_final$threshold[i]) == 2, best_models_final$threshold[i], paste0('0', best_models_final$threshold[i]))
  dz_name <- ifelse(best_models_final$name[i] == 'ws_pac', 'ws_pac_acr', best_models_final$name[i])
  test_name <- paste0(smote_dir, dz_name, '_smote_test_', thsh, '.csv')
  
  # load file
  df_test <- read.csv(test_name)
  
  # format
  df_test$Date <- paste(df_test$Year, df_test$Month, df_test$Day, sep = '-')
  df_test$Date <- as.Date(df_test$Date, '%Y-%m-%d')
  
  # subset data
  df <- df_test[, c('Latitude', 'Longitude', 'Date')]
  
  # combine
  validation_df <- rbind(validation_df, df)
}  

# remove duplicated entries
validation_df <- validation_df[!duplicated(validation_df), ]

# save 
# write.csv(validation_df, file = paste0(save_dir, 'forec_validation_df.csv'), row.names = F)

# find nearest reef grid point -------------------------------------------------
# library(sp)
library(raster)
library(rgdal)

# load data
load("../compiled_data/spatial_data/spatial_grid.Rds")

# format
validation_df$point.ID <- as.numeric(row.names(validation_df))

# extract reef ID where points overlap a reef grid pixel
xx <- extract(polygons_5km, cbind(validation_df$Longitude, validation_df$Latitude))

# join data and format

x <- validation_df %>%
  left_join(xx) %>%
  mutate(pixelID = layer)

x <- x[, c('Latitude', 'Longitude', 'Date', 'pixelID')]

# save 
write.csv(x, file = paste0(save_dir, 'forec_validation_df.csv'), row.names = F)
