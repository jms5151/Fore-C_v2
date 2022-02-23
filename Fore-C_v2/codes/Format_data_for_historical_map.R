# format historical data for map -------------------------------------------------------------
rm(list=ls()) #remove previous variable assignments

# load library
library(tidyverse)

# load data
load("../compiled_data/survey_data/GA.RData")
load("../compiled_data/survey_data/WS.RData")

observations <- rbind(ga[, c("Date", "Latitude", "Longitude", "Region", "Island", "Project")], 
                      ws[, c("Date", "Latitude", "Longitude", "Region", "Island", "Project")])

observations <- unique(observations)

# format location
observations$Location <- ifelse(observations$Region == "GBR", "Great Barrier Reef", as.character(observations$Island))

# format project
observations$Project[observations$Project == "Aeby_Kenyon"] <- "University of Hawaii at Manoa/USGS"
observations$Project[observations$Project == "Couch"] <- "Cornell University"
observations$Project[observations$Project == "Walsh"] <- "University of Hawaii at Hilo"
observations$Project[observations$Project == "Williams"] <- "Bangor University"
observations$Project[observations$Project == "RHIS"] <- "Eyes on the Reef, RHIS"
observations$Project[observations$Project == "Burns"|
                       observations$Project == "Caldwell"|
                       observations$Project == "Ross"|
                       observations$Project == "Runyon"|
                       observations$Project == "Walton"|
                       observations$Project == "White"] <- "University of Hawaii at Manoa"

# format data for historical survey map on shiny app
historical_data <- observations %>%
  group_by(Longitude, Latitude, Location, Project) %>%
  summarize(N = length(Longitude)
            , minYr = substr(min(Date),1,4)
            , maxYr = substr(max(Date),1,4)
            ) %>%
  filter(!is.na(Longitude))

# add pop up data
historical_data$survey_text <- paste0("<h3> <b> Location: </b>", historical_data$Location,
                           "<br> <b> Number of surveys: </b>", historical_data$N,
                           "<br> <b> Earliest survey: </b>", historical_data$minYr,
                           "<br> <b> Latest survey: </b>", historical_data$maxYr,
                           "<br> <b> Data source: </b>", historical_data$Project)

# make all longitudes negative to on same side of Pacific Ocean in leaflet
historical_data$Longitude <- ifelse(historical_data$Longitude>0, historical_data$Longitude-360, historical_data$Longitude)

# save data
save(historical_data, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Static_data/historical_surveys.RData")
