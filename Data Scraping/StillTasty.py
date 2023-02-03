from requests import get
from bs4 import BeautifulSoup
import pandas as pd
import numpy as np
import re

# Declare the normalization function:
def normalize(text):
    # Normalize the data so that all the time data is in !! DAYS !!
    # Search the string for 'day', 'week', 'month', 'year' as well as plural versions

    # if the string contains 'day' or 'days'
    if re.search('day|days', text):
        # split the string on 'day' or 'days'
        text = text.split('day')[0]
        
        # most of the data is in the form x-y days so we need to see if x or y is a range and if so take the average
        #     if the string contains '-'
        if re.search('-', text):
            # split the string on '-'
            text = text.split('-')
            # convert to int
            text = [int(i) for i in text]
            # take the average
            text = sum(text)/len(text)
        # if the string does not contain '-'
        else:
            # convert to int
            text = int(text)
        # convert to int
        text = int(text)
    # do the same for 'week' or 'weeks'
    elif re.search('week|weeks', text):
        text = text.split('week')[0]
        if re.search('-', text):
            text = text.split('-')
            text = [int(i) for i in text]
            text = sum(text)/len(text)
        else:
            text = int(text)
        text = int(text) * 7
    # do the same for 'month' or 'months'
    elif re.search('month|months', text):
        text = text.split('month')[0]
        if re.search('-', text):
            text = text.split('-')
            text = [int(i) for i in text]
            text = sum(text)/len(text)
        else:
            text = int(text)
        text = int(text) * 30
    # do the same for 'year' or 'years'
    elif re.search('year|years', text):
        text = text.split('year')[0]
        if re.search('-', text):
            text = text.split('-')
            text = [int(i) for i in text]
            text = sum(text)/len(text)
        else:
            text = int(text)
        text = int(text) * 365
    # if the string does not contain 'day', 'week', 'month', 'year' or their plural versions
    else:
        # set the value to Nan
        text = np.nan

    return text

url_list = [
            ['https://www.stilltasty.com/searchitems/index/26?page=', 'Fruits', 9 ], 
            # ['https://www.stilltasty.com/searchitems/index/9?page=', 'Dairy & Eggs', 8],
            # ['https://www.stilltasty.com/searchitems/index/27?page=', 'Meat & Poultry', 14],
            # ['https://www.stilltasty.com/searchitems/index/7?page=', 'Fish & Shellfish', 8],
            # ['https://www.stilltasty.com/searchitems/index/28?page=', 'Nuts, Grains & Pasta', 10],
            # ['https://www.stilltasty.com/searchitems/index/6?page=', 'Condiments & Oils', 8],
            # ['https://www.stilltasty.com/searchitems/index/31?page=', 'Snacks and Baked Goods', 15],
            # ['https://www.stilltasty.com/searchitems/index/30?page=', 'Herbs & Spices', 6],
            # ['https://www.stilltasty.com/searchitems/index/5?page=', 'Beverages', 6],
            ]


# define a list to store the dataframes
df_list = []

# loop through the url_list
for url in url_list:
    # get the url and name for each food group
    food_group_url = url[0]
    food_group_name = url[1]
    max_page = url[2]

    # create a dataframe to store the entire food group
    df = pd.DataFrame(columns = ['Label', 'Link','Fridge', 'Freezer', 'Pantry'])
    

    # loop through the pages
    for page in range(1, max_page + 1):
        # get the url
        url = food_group_url + str(page)

        # Get the HTML from the URL
        response = get(url)

        # Parse the HTML
        html_soup = BeautifulSoup(response.text, 'html.parser')

        # search for the class 'search-list'
        search_list = html_soup.find('div', class_ = 'search-list')

        # extract all the links from the search_list
        links = search_list.find_all('a')

        # extract the text from the links
        link_text = [link.text for link in links]

        # extract the href from the links
        link_href = [link.get('href') for link in links]

        # concat the data to the dataframe
        df = pd.concat([df, pd.DataFrame({'Label': link_text, 'Link': link_href})])

        print(df)

    # append the dataframe to the df_list
    df_list.append(df)


# Next Step is getting the food infomation from the links

# loop through every dataframe in the df_list
for df in df_list:
    # loop through every url in the dataframe
    for url in df['Link']:
        # get the HTML from the url
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

        
        # Normalize the expiration infomation so that they are all in a day format
        pantry = normalize(str(pantry))
        fridge = normalize(str(fridge))
        freezer = normalize(str(freezer))
        

        # add the data to it respective column in the dataframe
        df.loc[df['Link'] == url, 'Pantry'] = pantry
        df.loc[df['Link'] == url, 'Fridge'] = fridge
        df.loc[df['Link'] == url, 'Freezer'] = freezer


# print the first dataframe
print(df_list[0].head())

# export each data frame to a csv file with the filename being the name of the food group from the url list
for i in range(0, len(df_list)):
    df_list[i].to_csv(url_list[i][1] + '.csv', index = False, encoding = 'utf-8')

