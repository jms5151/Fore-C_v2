# Final co-variates in models for each disease and region

# open final model objects
GA_GBR_Model <- readRDS("../model_objects/ga_gbr.rds")
GA_Pacific_Model <- readRDS("../model_objects/ga_pac.rds")
WS_GBR_Model <- readRDS("../model_objects/ws_gbr.rds")
WS_Pacific_Model <- readRDS("../model_objects/ws_pac.rds")

# Growth anomalies GBR 
ga_gbr_vars <- names(GA_GBR_Model$importance[,1]) 

# Growth anomalies Pacific
ga_pac_vars <- names(GA_Pacific_Model$importance[,1])

# White syndromes Pacific (Acroporidae)
ws_pac_acr_vars <- names(WS_Pacific_Model$importance[,1]) 

# White syndromes GBR 
ws_gbr_vars <- names(WS_GBR_Model$importance[,1]) 
