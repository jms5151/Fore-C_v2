# Pull SST covariates to grid --------------------------------------------------

# load libraries
library(ncdf4)
library(tidyverse)

# source custom function 
source("./codes/custom_functions/fun_ftp_download.R")

# set crw forecast directory for downloads
crw_dir <- "../raw_data/covariate_data/CRW_dz_temp_metrics/crw_weekly_updates/"
dir.create(crw_dir)

# download netcdf files from CRW --------------------------------------
# list files and download
list_and_download_ftp_files(ftp_path = 'ftp://ftp.star.nesdis.noaa.gov/pub/sod/mecb/gliu/caldwell/weeklyupdate_20220131/'
                            , dest_dir = crw_dir)

list_and_download_ftp_files(ftp_path = 'ftp://ftp.star.nesdis.noaa.gov/pub/sod/mecb/gliu/caldwell/20220124/'
                            , dest_dir = crw_dir)


# load and format data ------------------------------------------------

# create empty data frame
sst_metrics <- data.frame()

# list files
nc_files <- list.files(crw_dir)

# open and format data (this should take 1-4 minutes on a standard laptop)
for(j in nc_files){
  # open netcdf file
  x <- nc_open(paste0(crw_dir, j))
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
}

# reshape files ----------------------------------------------
reef_grid_sst <- sst_metrics %>%
  spread(temp_metric_name, value) %>%
  fill(c("Hot_snaps", "SST_90dMean" , "Winter_condition"), .direction = 'updown')

# save data --------------------------------------------------
save(reef_grid_sst, 
     file = "../compiled_data/grid_covariate_data/grid_with_sst_metrics.RData")

# delete nc files --------------------------------------------
crw_dir2remove <- substr(crw_dir, 1, nchar(crw_dir)-1)
unlink(crw_dir2remove, recursive = TRUE)
