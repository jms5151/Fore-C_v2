# Extract SST metrics to survey data ---------------------------------------------------------------

# load libraries
# library(tidyverse)
# library(zoo)
# library(raster)
# library(RANN)

# load surey data
load("compiled_data/survey_data/Survey_points_with_dates.RData")

# expand dataframe to include row for all 90 days prior to survey date  ----------------------------
surveys$Survey_Date <- surveys$Date

surveys_90d <- surveys %>%
  group_by(Survey_Date, 
           Latitude, 
           Longitude
           ) %>%
  complete(Date = seq.Date(Date - 90, Date, by="day"))

save(surveys_90d, file = "compiled_data/survey_intermediate_covariate_data/suveys_90d_expanded.RData")

# extract SST data ---------------------------------------------------------------------------------
load("compiled_data/survey_intermediate_covariate_data/suveys_90d_expanded.RData")

dates_long <- sort(unique(surveys_90d$Date))
surveyDates2 <- gsub("-", "", dates_long)

newFileName2 <- "compiled_data/survey_intermediate_covariate_data/sst_surveys.csv"
sst.df <- data.frame(matrix(ncol = 4, nrow = 0))
colnames(sst.df) <- c("Latitude", "Latitude", "Date", "SST")
write.csv(sst.df, newFileName2, row.names = F)

for(i in 1:length(surveyDates2)){
  yr <- substr(surveyDates2[i], 1, 4)
  ncFileName <- paste0("I:/SST_CoralReefWatch/", # on laptop it's E:/
                       yr, 
                       "/coraltemp_v1.0_", 
                       surveyDates2[i], 
                       ".nc"
                       ) 
  ncTempBrick <- brick(ncFileName, 
                       varname = "analysed_sst"
                       )
  # do not worry about warning messages, they are providing information about the "brick" function
  df <- subset(surveys_90d, 
               Date == dates_long[i]
               )
  surveySST <- extract(ncTempBrick, 
                       cbind(df$Longitude, 
                             df$Latitude)
                       )
  if(anyNA(surveySST) == TRUE){
    surveySST <- extract(ncTempBrick, 
                         cbind(df$Longitude, 
                               df$Latitude
                               ), 
                         method = "bilinear"
                         )
    temp.df <- data.frame("Latitude" = df$Latitude, 
                          "Longitude" = df$Longitude, 
                          "Date" = dates_long[i], 
                          "SST" = surveySST
                          )
  } else {
    temp.df <- data.frame("Latitude" = df$Latitude, 
                          "Longitude" = df$Longitude, 
                          "Date" = dates_long[i], 
                          "SST" = surveySST[,]
                          )
  }
  write.table(temp.df, 
              file = newFileName2, 
              row.names = F, 
              sep = ",", 
              col.names = !file.exists(newFileName2), 
              append = T
              )
  # indicate progress periodically
  if(i %in% seq(500, 5000, by = 500)){
    cat("finished", 
        i, 
        "of", 
        length(surveyDates2), 
        ":", 
        as.character(dates_long[i]), 
        "\n"
        )
    }
}

# calculate 90 day mean sst for all surveys -------------------------------------------------------
# load data from above
load("compiled_data/survey_intermediate_covariate_data/suveys_90d_expanded.RData")
sst <- read.csv("compiled_data/survey_intermediate_covariate_data/sst_surveys.csv")

# format data
surveys_90d <- as.data.frame(surveys_90d)
sst$Date <- as.Date(sst$Date,"%Y-%m-%d")

# make SST calculations and rename survey date
sst_90d <- surveys_90d %>%
  left_join(sst, 
            by = c("Date", 
                   "Latitude", 
                   "Longitude"
                   )
            ) %>%
  group_by(Survey_Date, 
           Longitude, 
           Latitude
           ) %>%
  summarise(SST_90dMean = mean(SST, na.rm = T)) %>%
  rename(Date = Survey_Date)

# save
save(sst_90d, file = "compiled_data/survey_covariate_data/surveys_sst_90dMean.RData")

# extract CRW SST disease metrics for all surveys --------------------------------------------------
# load files: these are big, so takes a little bit of time
WC <- read.csv("raw_data/CRW_dz_temp_metrics/forec_wintcond.csv", header = F, check.names = F)
HS <- read.csv("raw_data/CRW_dz_temp_metrics/forec_hotsnap.csv", header = F, check.names = F)
CS <- read.csv("raw_data/CRW_dz_temp_metrics/forec_coldsnap.csv", header = F, check.names = F)

getSSTmetric <- function(df, df_points){
  # format data frame, which initially has two header rows of lon/lat coordinates 
  # and the first column is date
  colnames(df) <- paste0(df[1,], "AND", df[2,])
  df <- df[-c(1,2),]
  firstCol <- colnames(df[2])
  lastCol <- colnames(df[ncol(df)])
  df <- gather(df, 
               key = "Coords", 
               value = sst_name, 
               all_of(firstCol):all_of(lastCol)
               )
  df <- df %>% 
    separate(Coords, 
             c("Longitude", 
               "Latitude"
               ), 
             "AND"
             )
  df$Date <- as.Date(df$`PIXLON:ANDPIXLAT:`, "%Y%b%d")
  # find sst metric for each survey location 
  nearTable <- as.data.frame(nn2(data = subset(df, 
                                               select = c(Longitude, 
                                                          Latitude, 
                                                          Date
                                                          )
                                               ), 
                                 query = subset(df_points, 
                                                select = c(Longitude, 
                                                           Latitude, 
                                                           Date
                                                           )
                                                ), 
                                 k = 1
                                 )
                             )
  df$sst_name[nearTable$nn.idx]
}


# be patient, this function takes some time too
surveys$Winter_condition <- getSSTmetric(WC, surveys)
surveys$Hot_snaps <- getSSTmetric(HS, surveys)
surveys$cold_snaps <- getSSTmetric(CS, surveys)

# rename and save data
sst_metrics <- surveys
save(sst_metrics, file = "compiled_data/survey_covariate_data/surveys_with_CRW_sst_metrics.RData")

# extract SST anomaly data -------------------------------------------------------------------------
dates <- sort(unique(surveys$Date))

newFileName3 <- "compiled_data/survey_intermediate_covariate_data/ssta_surveys.csv"
surveys_ssta <- data.frame(matrix(ncol = 4, nrow = 0))
colnames(surveys_ssta) <- c("Date", "Latitude", "Longitude", "ssta")
write.csv(surveys_ssta, newFileName3, row.names = F)

for(j in 2:length(dates)){
  # subset surveys
  df <- subset(surveys, Date == dates[j])
  year <- substr(dates[j], 1, 4)
  # open SST anomalies file for date
  ## fix filename
  ssta_filename <- paste0('I:/SSTanomaly_CRW/', 
                          year, 
                          '/ct5km_ssta_v3.1_', 
                          gsub("-", 
                               "", 
                               dates[j]
                               ), 
                          '.nc')
  ssta_raster <- brick(ssta_filename)
  # extract data for each survey point
  df$ssta <- extract(ssta_raster, 
                     cbind(df$Longitude, 
                           df$Latitude
                           )
                     )
  # save data
  write.table(df, 
              file = newFileName3, 
              row.names = F, 
              sep = ",", 
              col.names = !file.exists(newFileName3), 
              append = T
              )
  # indicate status of loop every 100th run  
  if(j/100 == 0){
    cat(paste0(j, " done"))
  }
}

# save as RData frame
ssta_surveys <- read.csv("compiled_data/survey_intermediate_covariate_data/ssta_surveys.csv")
ssta_surveys$Date <- as.Date(ssta_surveys$Date, "%Y-%m-%d")
save(ssta_surveys, file = "compiled_data/survey_covariate_data/surveys_ssta.RData")
