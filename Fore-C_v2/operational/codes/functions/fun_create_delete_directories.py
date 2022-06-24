# -*- coding: utf-8 -*-
"""
Functions to create and delete directories
Last update: 2022-June-23
"""

# load modules
import os

def create_dir(path): 
    os.makedirs(path)
    
def delete_dir(path):
    files = os.listdir(path)
    for m in files:
        os.remove(path + m)
    os.rmdir(path)