# -*- coding: utf-8 -*-
"""
Created on Fri May 13 15:25:23 2022

@author: jamie
"""

def winter_condition_offset(df, crw_vs_region_name, offset_value):
    ind = df.index[df.CRW_VS_region == crw_vs_region_name].tolist()
    df.loc[ind, 'Winter_condition'] = df.loc[ind, 'Winter_condition'] - offset_value