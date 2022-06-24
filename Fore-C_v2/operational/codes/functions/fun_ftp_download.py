# -*- coding: utf-8 -*-
"""
Code to list files from website
Last update: 2022-Apr-25
"""

import requests # v2.27.1
from bs4 import BeautifulSoup # v4.11.1

def list_ftp_files(ftp_path):
    reqs = requests.get(ftp_path)
    soup = BeautifulSoup(reqs.text, 'html.parser')
    urls = []
    for link in soup.find_all('a'): 
        urls.append(link.get('href'))
    return urls