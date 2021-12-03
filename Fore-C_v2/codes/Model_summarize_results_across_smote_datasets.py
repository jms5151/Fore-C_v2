# -*- coding: utf-8 -*-
# load libraries
import pandas as pd

# load data
x = pd.read_csv("../model_selection_summary_results/qf_smote_summary.csv")

# select rows with best models
# select rows based on parsimonious best models
x2 = x.loc[(x['selection'] == 'parsimonious_best')]

# for each disease-region, select rows with highest Adj R2 values 
x2 = x2.sort_values('AdjR2_withheld_sample', ascending = False).drop_duplicates(['Disease_type'])

# save
x2.to_csv('../model_selection_summary_results/parsimonious_best_models_by_disease_and_region.csv', index = False)
