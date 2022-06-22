# Plot model residuals


# Load functions, model objects, and data --------------------------------------

# source custom functions
source("./codes/custom_functions/fun_plot_residuals.R")

# open final model objects
source("./codes/Final_covariates_by_disease_and_region.R")

# load data
smote_dir <- '../compiled_data/survey_data/smote_datasets/'
ga_gbr_data <- read.csv(paste0(smote_dir, 'ga_gbr_smote_test_15.csv'))
ga_pac_data <- read.csv(paste0(smote_dir, 'ga_pac_smote_test_20.csv'))
ws_gbr_data <- read.csv(paste0(smote_dir, 'ws_gbr_smote_test_10.csv'))
ws_pac_acr_data <- read.csv(paste0(smote_dir, 'ws_pac_acr_smote_test_10.csv'))

# create residual plots --------------------------------------------------------
resid_plots(
  mod = GA_GBR_Model
  , newdata = ga_gbr_data
  , title = 'ga_gbr_residuals'
  , yVar = 'Y'
  )

resid_plots(
  mod = GA_Pacific_Model
  , newdata = ga_pac_data
  , title = 'ga_pac_residuals'
  , yVar = 'p'
)

resid_plots(
  mod = WS_Pacific_Model
  , newdata = ws_pac_acr_data
  , title = 'ws_pac_residuals'
  , yVar = 'p'
)

resid_plots(
  mod = WS_GBR_Model
  , newdata = ws_gbr_data
  , title = 'ws_gbr_residuals'
  , yVar = 'Y'
)


