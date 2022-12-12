from requests import get
from bs4 import BeautifulSoup
import pandas as pd
import numpy as np
import re


url = 'https://www.stilltasty.com/Fooditems/index/16373'

df = pd.DataFrame(columns = ['Label', 'Link','Fridge', 'Freezer', 'Pantry'])


response = get(url)

# parse the HTML
html_soup = BeautifulSoup(response.text, 'html.parser')

# search for the class 'storage'
container = html_soup.find('div', class_ = 'food-storage-container')

# NOTE - The way the website is structered, there are 3 different images 
#  1. Pantry - food-storage-left pantryimg1
#  2. Fridge - food-storage-left pantryimg2
#  3. Freezer - food-storage-left pantryimg3

# declare empty variables as Nan
pantry = np.nan
fridge = np.nan
freezer = np.nan


# if the class 'food-storage-left pantryimg1' exists
if container.find('div', class_ = 'food-storage-right image1'):
    #extract the data in class 'food-storage-right image1'
    pantry_container = container.find('div', class_ = 'food-storage-right image1')
    # find the span
    pantry = pantry_container.find('span').text
    # strip the white space
    pantry = pantry.strip()

# if the class 'food-storage-left pantryimg2' exists
if container.find('div', class_ = 'food-storage-right image2'):
    #extract the data in class 'food-storage-right image2'
    fridge_container = container.find('div', class_ = 'food-storage-right image2')
    # find the span
    fridge = fridge_container.find('span').text
    # strip the white space
    fridge = fridge.strip()

# if the class 'food-storage-left pantryimg3' exists
if container.find('div', class_ = 'food-storage-right image3'):
    #extract the data in class 'food-storage-right image3'
    container = container.find('div', class_ = 'food-storage-right image3')
    # find the span
    freezer = container.find('span').text
    # strip the white space
    freezer = freezer.strip()







# print results
print(pantry)
print(fridge)
print(freezer)


