from requests import get
from bs4 import BeautifulSoup
import pandas as pd
import numpy as np
import re



url_list = [['http://www.eatbydate.com/dairy/', 'Dairy Products'],
            ['http://www.eatbydate.com/drinks/', 'Drinks Products'],
            ['http://www.eatbydate.com/fruits/', 'Fruits Products'],
            ['http://www.eatbydate.com/vegetables/', 'Vegetables Products'],
            ['http://www.eatbydate.com/grains/', 'Grains Products'],
            ['http://www.eatbydate.com/proteins/', 'Proteins Products'],
            ['http://www.eatbydate.com/other/', 'Other Products']]


# define a list to store the dataframes
df_list = []

# loop through the url_list to get the url and name for each food group
for url in url_list:
    # get the url and name for each food group
    food_group_url = url[0]
    food_group_name = url[1]

    # Get the HTML from the URL
    url = food_group_url
    response = get(url)

    # Parse the HTML
    html_soup = BeautifulSoup(response.text, 'html.parser')

    # Get all 'col content-wrapper' divs
    divs = html_soup.find_all('div', class_ = 'col content-wrapper')

    # Search divs for the h2 class with the string food_group_name
    for div in divs:
        if div.find('h2', string = food_group_name):
            food_data_div = div

    # extract all the links from the food_data_div
    links = food_data_div.find_all('a')

    # extract the text from the links
    link_text = [link.text for link in links]

    # extract the href from the links
    link_href = [link.get('href') for link in links]

    # create a dataframe from the link_text and link_href
    df = pd.DataFrame({'Label': link_text, 'Link': link_href})

    # append the dataframe to the df_list
    df_list.append(df)


# concatenate the dataframes in the df_list
df = pd.concat(df_list)
