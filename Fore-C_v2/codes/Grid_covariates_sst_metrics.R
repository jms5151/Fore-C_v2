# Pull SST covariates to grid --------------------------------------------------

# load libraries
library(ncdf4)
library(tidyverse)
library(httr)

# source custom function 
source("./codes/custom_functions/fun_ftp_download.R")

# list weekly SST files -----------------------------------------------

parent_ftp_filepath <- 'ftp://ftp.star.nesdis.noaa.gov/pub/sod/mecb/crw/data/for_forec/shiny_app/'

# list directories, named by date
files <- list_ftp_files(ftp_path = parent_ftp_filepath)

parent_file <- max(as.numeric(files), na.rm = T)

child_ftp_filepath <- paste0(parent_ftp_filepath, parent_file, '/')

files <- list_ftp_files(ftp_path = child_ftp_filepath)

# load and format data ------------------------------------------------

# create empty data frame
sst_metrics <- data.frame()

# open and format data (this should take 1-4 minutes on a standard laptop)
for(j in files){
  # open data
  ftp_path_tmp <- paste0(child_ftp_filepath, j)
  res <- GET(ftp_path_tmp, write_disk(basename(ftp_path_tmp), overwrite = TRUE))
  x <- nc_open(res$request$output$path)
  # get ids
  ids <- ncvar_get(x, varid = "reef_id")
  # get date(s)
  dates <- ncvar_get(x, varid = "data_date")
  # determine metric name
  if(grepl('hotsnap|hdw', j) == TRUE){
    metric_name <- 'Hot_snaps'
  } else if(grepl('mean-90d', j) == TRUE){
    metric_name <- 'SST_90dMean'
  } else {
    metric_name <- 'Winter_condition'
  }
  # determine if each file is a cfs forecast (True) or satellite measurement (False) 
  cfs <- ifelse(grepl('cfsv2', j) == TRUE, TRUE, FALSE)
  # format forecasts
  if(cfs == TRUE){
    metric_array <- ncvar_get(x, varid = names(x$var)[1])
    tmp_df <- data.frame()
    for(k in 1:12){ # dates
      for(l in 1:28){ # ensembles
        tmp_metric <- metric_array[, l, k]
        # make flagged values NAs
        tmp_metric[tmp_metric == 253|tmp_metric == 9999] <- NA
        # fill in NAs with median values
        tmp_metric[is.na(tmp_metric)] <- median(tmp_metric, na.rm = T)
        # create dataframe
        cfs_df <- data.frame("ID" = ids
                             , "Date" = dates[k]
                             , "ensemble" = l
                             , "type" = "forecast"
                             , "temp_metric_name" = metric_name
                             , "value" = tmp_metric
                             )
        tmp_df <- rbind(tmp_df, cfs_df)
        }
      }
    # format sst measurements
    } else if (cfs == FALSE){
    tmp_metric <- ncvar_get(x, varid = names(x$var)[1])
    # make flagged values NAs
    tmp_metric[tmp_metric == 253|tmp_metric == 9999] <- NA
    # fill in NAs with median values
    tmp_metric[is.na(tmp_metric)] <- median(tmp_metric, na.rm = T)
    # create dataframe
    tmp_df <- data.frame("ID" = ids
                         , "Date" = dates
                         , "ensemble" = 0
                         , "type" = "nowcast"
                         , "temp_metric_name" = metric_name
                         , "value" = tmp_metric
                         )
    }
  # combine data
  sst_metrics <- rbind(sst_metrics
                       , tmp_df)
  nc_close(x)
  file.remove(j)
  cat("finished ", j, '\n')
}

# files <- files[which(files == j):length(files)]

# reshape files ----------------------------------------------
reef_grid_sst <- sst_metrics %>%
  spread(key = temp_metric_name, value = value) %>%
  fill(c("Hot_snaps", "SST_90dMean" , "Winter_condition"), .direction = 'updown')

# format dates
reef_grid_sst$Date <- as.Date(reef_grid_sst$Date, "%Y-%m-%d")

# Add regions and offset wdw here
# add region, then update winter condition based on region
load('../compiled_data/spatial_data/grid.RData')
reef_grid_sst <- reef_grid_sst %>%
  left_join(reefsDF)

reef_grid_sst$Region[reef_grid_sst$Longitude >= 140 & reef_grid_sst$Longitude <= 155 & reef_grid_sst$Latitude >= -28 & reef_grid_sst$Latitude <= -7] <- "gbr"
reef_grid_sst$Region[reef_grid_sst$Longitude >= -180 & reef_grid_sst$Longitude <= -152 & reef_grid_sst$Latitude >= 18 & reef_grid_sst$Latitude <= 30] <- "hawaii"
reef_grid_sst$Region[reef_grid_sst$Longitude >= 143 & reef_grid_sst$Longitude <= 147 & reef_grid_sst$Latitude >= 12 & reef_grid_sst$Latitude <= 21] <- "guam-cnmi"
reef_grid_sst$Region[reef_grid_sst$Longitude >= -174 & reef_grid_sst$Longitude <= -167 & reef_grid_sst$Latitude >= -16 & reef_grid_sst$Latitude <= -10] <- "samoas"
reef_grid_sst$Region[reef_grid_sst$Longitude >= 165 & reef_grid_sst$Longitude <= 168 & reef_grid_sst$Latitude >= 18 & reef_grid_sst$Latitude <= 21] <- "wake"
reef_grid_sst$Region[reef_grid_sst$Longitude >= -171 & reef_grid_sst$Longitude <= -168 & reef_grid_sst$Latitude >= 15 & reef_grid_sst$Latitude <= 18] <- "johnston"
reef_grid_sst$Region[reef_grid_sst$Longitude >= -178 & reef_grid_sst$Longitude <= -175 & reef_grid_sst$Latitude >= -1 & reef_grid_sst$Latitude <= 2] <- "howland-baker"
reef_grid_sst$Region[reef_grid_sst$Longitude >= -161 & reef_grid_sst$Longitude <= -159 & reef_grid_sst$Latitude >= -2 & reef_grid_sst$Latitude <= 1] <- "jarvis"
reef_grid_sst$Region[reef_grid_sst$Longitude >= -164 & reef_grid_sst$Longitude <= -161 & reef_grid_sst$Latitude >= 4 & reef_grid_sst$Latitude <= 8] <- "palmyra-kingman"

reef_grid_sst$Winter_condition <- ifelse(reef_grid_sst$Region == 'guam-cnmi', reef_grid_sst$Winter_condition - 3.73, reef_grid_sst$Winter_condition)
reef_grid_sst$Winter_condition <- ifelse(reef_grid_sst$Region == 'howland-baker', reef_grid_sst$Winter_condition - 19.25, reef_grid_sst$Winter_condition)
reef_grid_sst$Winter_condition <- ifelse(reef_grid_sst$Region == 'johnston', reef_grid_sst$Winter_condition - 2.85, reef_grid_sst$Winter_condition)
reef_grid_sst$Winter_condition <- ifelse(reef_grid_sst$Region == 'samoas', reef_grid_sst$Winter_condition - 4.00, reef_grid_sst$Winter_condition)
reef_grid_sst$Winter_condition <- ifelse(reef_grid_sst$Region == 'gbr', reef_grid_sst$Winter_condition - 1.95, reef_grid_sst$Winter_condition)
reef_grid_sst$Winter_condition <- ifelse(reef_grid_sst$Region == 'hawaii', reef_grid_sst$Winter_condition - 2.73, reef_grid_sst$Winter_condition)
reef_grid_sst$Winter_condition <- ifelse(reef_grid_sst$Region == 'jarvis', reef_grid_sst$Winter_condition - 18.96, reef_grid_sst$Winter_condition)
reef_grid_sst$Winter_condition <- ifelse(reef_grid_sst$Region == 'palmyra-kingman', reef_grid_sst$Winter_condition - 7.01, reef_grid_sst$Winter_condition)
reef_grid_sst$Winter_condition <- ifelse(reef_grid_sst$Region == 'wake', reef_grid_sst$Winter_condition - 4.01, reef_grid_sst$Winter_condition)

# remove Region
reef_grid_sst$Region <- NULL

# save data --------------------------------------------------
save(reef_grid_sst, 
     file = "../compiled_data/grid_covariate_data/grid_with_sst_metrics.RData")
