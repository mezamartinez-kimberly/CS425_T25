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
    df = pd.DataFrame(columns = ['Label', 'Link'])
    

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


