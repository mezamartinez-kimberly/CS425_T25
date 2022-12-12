from requests import get
from bs4 import BeautifulSoup
import pandas as pd
import numpy as np
import re


url_list = [['https://www.stilltasty.com/searchitems/index/26?page=', 'Fruits', 9],
            ['https://www.stilltasty.com/searchitems/index/25?page=', 'Vegetables', 14],
            ['https://www.stilltasty.com/searchitems/index/9?page=', 'Dairy & Eggs', 8],
            ['https://www.stilltasty.com/searchitems/index/10?page=', 'Meat & Poultry', 14],
            ['https://www.stilltasty.com/searchitems/index/7?page=', 'Fish & Shellfish', 8],
            ['https://www.stilltasty.com/searchitems/index/28?page=', 'Nuts, Grains & Pasta', 10],
            ['https://www.stilltasty.com/searchitems/index/6?page=', 'Baking & Spices', 8],
            ['https://www.stilltasty.com/searchitems/index/8?page=', 'Snacks and Baked Goods', 15],
            ['https://www.stilltasty.com/searchitems/index/30?page=', 'Herbs & Spices', 6],
            ['https://www.stilltasty.com/searchitems/index/31?page=', 'Beverages', 6],
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


        # add the data to it respective column in the dataframe
        df.loc[df['Link'] == url, 'Pantry'] = pantry
        df.loc[df['Link'] == url, 'Fridge'] = fridge
        df.loc[df['Link'] == url, 'Freezer'] = freezer


# print the first dataframe
print(df_list[0].head())

# export each data frame to a csv file with the filename being the name of the food group from the url list
for i in range(0, len(df_list)):
    df_list[i].to_csv(url_list[i][1] + '.csv', index = False, encoding = 'utf-8')

