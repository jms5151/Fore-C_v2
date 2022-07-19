# -*- coding: utf-8 -*-
"""
Unzip compressed files from repository
Last update: 2022-June-23
"""

# load module
import zipfile

# function to unzip file
def unzip_dir(zip_filepath, dest_filepath):
    with zipfile.ZipFile(zip_filepath, 'r') as zip_ref:
        zip_ref.extractall(dest_filepath)

# unzip
unzip_dir(zip_filepath = '../model_objects.zip', dest_filepath = '../')
unzip_dir(zip_filepath = '../input_data.zip', dest_filepath = '../')
