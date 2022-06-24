# -*- coding: utf-8 -*-
"""
Code to list files from website
Last update: 2022-May-13
"""

def winter_condition_offset(df, crw_vs_region_name, offset_value):
    ind = df.index[df.CRW_VS_region == crw_vs_region_name].tolist()
    df.loc[ind, 'Winter_condition'] = df.loc[ind, 'Winter_condition'] - offset_value