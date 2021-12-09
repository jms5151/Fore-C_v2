# -*- coding: utf-8 -*-
"""
Created on Thu Dec  9 12:16:50 2021

@author: jamie
"""

# Initial co-variates to test in models for each disease and region

# Growth anomalies Pacific -----------------------
ga_pac_vars = ["Month",
                 "Median_colony_size",
                 "CV_colony_size",
                 "Poritidae_mean_cover",
                 "H_abund",
                 "SST_90dMean",
                 "Winter_condition",
                 "Hot_snaps",
                 "BlackMarble_2016_3km_geo.3",
                 "Long_Term_Kd_Median"
                 ]

# Growth anomalies GBR --------------------------
ga_gbr_vars = ["Month",
                 "Coral_cover",
                 "Fish_abund",
                 "SST_90dMean",
                 "Winter_condition",
                 "Hot_snaps",
                 "Long_Term_Kd_Median",
                 "Long_Term_Kd_Variability",
                 "Three_Week_Kd_Median",
                 "Three_Week_Kd_Variability"
                ]

# White syndromes Pacific (Acroporidae) -------
ws_pac_acr_vars = ["Month",
                     "Median_colony_size",
                     "Winter_condition",
                     "Long_Term_Kd_Median",
                     "Three_Week_Kd_Median"
                   ]

# White syndreoms GBR -------------------------
ws_gbr_vars = ["Month", 
                 "Coral_cover", 
                 "Fish_abund", 
                 "Winter_condition",
                 "Hot_snaps",
                 "Three_Week_Kd_Variability"
               ]

