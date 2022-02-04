# Run scenarios using quantile regression models

source("./codes/custom_functions/fun_quant_forest_predict.R")

# open final model objects
source("./codes/Final_covariates_by_disease_and_region.R")

# set up directory filepaths
scenario_dir <- "../compiled_data/scenarios_inputs/"
x <- list.files(scenario_dir, full.names = TRUE)

scenarios_save_dir <- "../compiled_data/scenarios_outputs/"
dir.create(scenarios_save_dir)

# open input files
lapply(x, load, .GlobalEnv)

# run scenarios --------
# GA GBR
ga_gbr_scenarios <- qf_predict_scenarios(df = ga_gbr_scenarios
                                         , regionGBRtrue = TRUE
                                         , family = ""
                                         , final_mod = GA_GBR_Model
                                         )

# pre-calculate disease risk change
# may want to use UprEstimate
ga_gbr_scenarios$disease_risk_change <- round((ga_gbr_scenarios$estimate - ga_gbr_scenarios$value) * 10)
# can't decrease more than 100%
ga_gbr_scenarios$disease_risk_change[ga_gbr_scenarios$disease_risk_change < -100] <- -100
# save data to run and then replace with same name
save(ga_gbr_scenarios, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/ga_gbr_scenarios.RData")

# WS GBR
ws_gbr_scenarios <- qf_predict_scenarios(df = ws_gbr_scenarios
                                         , regionGBRtrue = TRUE
                                         , family = ""
                                         , final_mod = WS_GBR_Model
                                         )

# pre-calculate disease risk change
ws_gbr_scenarios$disease_risk_change <- round((ws_gbr_scenarios$estimate - ws_gbr_scenarios$value) * 10)
# can't decrease more than 100%
ws_gbr_scenarios$disease_risk_change[ws_gbr_scenarios$disease_risk_change < -100] <- -100
# save data to run and then replace with same name
save(ws_gbr_scenarios, file = "../uh-noaa-shiny-app/forec_shiny_app_data/Scenarios/ws_gbr_scenarios.RData")


