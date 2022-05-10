# -*- coding: utf-8 -*-
"""
Created on Mon Apr 25 18:32:08 2022

@author: jamie
"""

import requests
from bs4 import BeautifulSoup

def list_ftp_files(ftp_path):
    reqs = requests.get(ftp_path)
    soup = BeautifulSoup(reqs.text, 'html.parser')
    urls = []
    for link in soup.find_all('a'): 
        urls.append(link.get('href'))
    return urls
