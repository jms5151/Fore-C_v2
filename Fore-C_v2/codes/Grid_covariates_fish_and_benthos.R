# extract fish and benthic data to grid
# load libraries
library(rgdal)
library(sf)
library(sp)
library(tidyverse)
library(raster)
library(rgeos)
library(zoo)

# load data
load("../compiled_data/spatial_data/grid.RData")
load("../raw_data/covariate_data/benthic_and_fish/Benthic_cover_by_noaa_sector.RData")
load("../raw_data/covariate_data/benthic_and_fish/Fish_abundance_by_noaa_sector.RData")
shapename <- shapefile('../raw_data/covariate_data/benthic_and_fish/NOAA_shapefiles/ALLPacific_Sectors_Islands.shp')
r = raster("../raw_data/covariate_data/benthic_and_fish/GBR_LTMP_Fish-Herbivores/LTMP_Fish-Herbivores-Value.asc") 
rhis_surveys <- read.csv("../raw_data/survey_data/GBRMPA_RHIS_01012009-18092020.csv")
load("../compiled_data/survey_data/GA.RData")
load("../compiled_data/survey_data/WS.RData")

# custom functions
source("codes/custom_functions/fun_aggregate_point_values_within_pixels.R")
source("codes/custom_functions/fun_calculate_coral_metrics.R")

# NOAA data ----------------------------------------------------------------
# extract points from nearest noaa sectors shapefile
dat <- reefsDF[, c("Longitude", "Latitude")]
coordinates(dat) = ~Longitude+Latitude
proj4string(dat) = CRS("+init=epsg:4326") 

# Set up containers for results
reefsDF$Island_code <- NA
reefsDF$Sector <- NA
reefsDF$DistanceToNearestSector <- NA

# For each point, find name of nearest polygon (this takes a bit of time)
minNOAArow <- which.max(reefsDF$ID[reefsDF$Region == "gbr"])
for (i in minNOAArow:nrow(reefsDF)) {
  gDists <- gDistance(dat[i,], shapename, byid=TRUE)
  reefsDF$Island_code[i] <- shapename$ISLAND_CD[which.min(gDists)]
  reefsDF$Sector[i] <- shapename$SEC_NAME[which.min(gDists)]
  reefsDF$DistanceToNearestSector[i] <- min(gDists)
}

# calculate median coral sizes based on survey data (same for each family so could switch df = ga with df = ws)
reefsDF$Median_colony_size_Acroporidae <- calc_colony_vals(df = ga, 
                                                           fam = "Acroporidae", 
                                                           colony_metric = "Median_colony_size",
                                                           col_fun = median)

reefsDF$Median_colony_size_Poritidae <- calc_colony_vals(df = ga,
                                                         fam = "Poritidae",
                                                         colony_metric = "Median_colony_size",
                                                         col_fun = median)

# calculate CV coral sizes based on survey data (also doesn't differ for each family)
reefsDF$CV_colony_size_Acroporidae <- calc_colony_vals(df = ga,
                                                       fam = "Acroporidae",
                                                       colony_metric = "CV_colony_size",
                                                       col_fun = mean)

reefsDF$CV_colony_size_Poritidae <- calc_colony_vals(df = ga,
                                                     fam = "Poritidae",
                                                     colony_metric = "CV_colony_size",
                                                     col_fun = mean)

# merge benthic and fish data
noaa_benthic_and_fish <- reefsDF %>%
  filter(Region != 'gbr') %>%
  left_join(noaa_benthic_sub[,c("Sector", "Poritidae_mean_cover", "Acroporidae_mean_cover")], by = "Sector") %>%
  left_join(noaa_fish_sub[,c("Sector", "H_abund", "Parrotfish_abund", "Butterflyfish_abund")], by = "Sector") %>%
  group_by(Region) %>%
  mutate_at("Median_colony_size_Acroporidae", zoo::na.aggregate) %>%
  mutate_at("Median_colony_size_Poritidae", zoo::na.aggregate) %>%
  mutate_at("CV_colony_size_Acroporidae", zoo::na.aggregate) %>%
  mutate_at("CV_colony_size_Poritidae", zoo::na.aggregate) %>%
  mutate_at("Poritidae_mean_cover", zoo::na.aggregate) %>%
  mutate_at("Acroporidae_mean_cover", zoo::na.aggregate) %>%
  mutate_at("H_abund", zoo::na.aggregate) %>%
  mutate_at("Parrotfish_abund", zoo::na.aggregate) %>%
  mutate_at("Butterflyfish_abund", zoo::na.aggregate)

# GBR data ----------------------------------------------------------------
# extract fish data by grid
fish <- extract(r, cbind(reefsDF$Longitude, reefsDF$Latitude))
fish_gbr <- cbind(reefsDF, "Fish_abund" = fish)

# calculate mean coral cover based on RHIS surveys
reefsDF$Coral_cover <- aggregate_point_values(rhis_surveys, "Plate.Table.Coral....Total.", mean)

gbr_benthic_and_fish <- fish_gbr %>%
  left_join(reefsDF) %>%
  filter(Region == 'gbr') %>%
  # there's no missing data, but for completeness in case of future updates:
  mutate_at("Fish_abund", zoo::na.aggregate) %>%
  mutate_at("Coral_cover", zoo::na.aggregate) 

# add columns, bind, and save data --------------------------------------------
# add missing columns
cols_to_add_to_gbr <- setdiff(colnames(noaa_benthic_and_fish), colnames(gbr_benthic_and_fish))
gbr_benthic_and_fish[, cols_to_add_to_gbr] <- NA

cols_to_add_to_noaa <- setdiff(colnames(gbr_benthic_and_fish), colnames(noaa_benthic_and_fish))
noaa_benthic_and_fish[, cols_to_add_to_noaa] <- NA

# reorder 
gbr_benthic_and_fish <- gbr_benthic_and_fish[, order(colnames(noaa_benthic_and_fish))]

# combine
benthic_and_fish_data <- rbind(noaa_benthic_and_fish, gbr_benthic_and_fish)

save(benthic_and_fish_data, file = "../compiled_data/grid_covariate_data/grid_with_benthic_and_fish_data.RData")
