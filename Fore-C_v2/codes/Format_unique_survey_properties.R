# Extract unique survey information ---------------------------

# load libraries
# library(data.table)

# load data
# source("codes/initial_survey_formatting.R")

survey_colnames <- c("Date", "Latitude", "Longitude")

# combine data and format column names
surveys <- rbindlist(list(esd0812[, survey_colnames], 
                          esd1317[, survey_colnames],
                          hicordis[, survey_colnames],
                          guam[, survey_colnames],
                          gbr[, survey_colnames]
                          )
                     )

# subset unique data
surveys <- unique(surveys)

# save data
save(surveys, file = "../compiled_data/survey_data/Survey_points_with_dates.RData")

# subset to locations only
surveys <- surveys[, c("Latitude", "Longitude")]
surveys <- unique(surveys)
save(surveys, file = "../compiled_data/survey_data/Survey_points.RData")
