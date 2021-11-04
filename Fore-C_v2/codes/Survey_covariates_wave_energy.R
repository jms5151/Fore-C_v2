# Extract wave energy data ---------------------------------------------------------------
# load libraries
# library(ncdf4)
# library(raster)

# load wave energy data
wave_mean_nc <- brick("raw_data/covariate_data/sesync_wave_energy_data/msec_wave_mean.nc")

# load survey data
load("compiled_data/survey_data/Survey_points.RData")

# extract wave energy data by survey points
survey_wave_mean <- extract(wave_mean_nc, 
                            cbind(surveys$Longitude, 
                                  surveys$Latitude
                                  )
                            )

# add wave energy data to surveys
surveys$wave_mean <- survey_wave_mean

# rename and save data
wave_energy <- surveys
save(wave_energy, file = "compiled_data/survey_covariate_data/surveys_with_wave_energy.RData")