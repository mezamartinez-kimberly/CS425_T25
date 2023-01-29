from requests import get
from bs4 import BeautifulSoup
import pandas as pd
import numpy as np
import re
import os
import csv


path = 'Data Scraping/CSV'

# loop through all the csv files in the path
for csv in os.listdir(path):

    # chanfe the directory to the path
    os.chdir(path)

    with open(csv, 'r') as file:
        reader = csv.reader(file)
        headers = next(reader)
        headers.append('Food Name')
        headers.append('isOpened')
        data = []
        for row in reader:
            label = row[0]
            name, status = label.split('-')
            name = name.strip()
            isOpened = True if status.strip() == 'OPENED PACKAGE' else False
            row.append(name)
            row.append(isOpened)
            data.append(row)

    with open(csv, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(headers)
        for row in data:
            writer.writerow(row)
