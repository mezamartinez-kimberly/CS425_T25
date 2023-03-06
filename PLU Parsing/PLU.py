# NOTE: the input file: "input.csv" has 2 columns of data, the first column is the PLU Code and the second column is the Food Name
# there are duplicate food names but not duplicate PLU codes
# this means that mulitple PLU codes can reference the same food name

# The goal of this python script is to parse the input file into 2 seperate files
# File 1: PLU.csv
# This file will contain the PLU ID, PLU, and a reference to the Food Name ID from the Food.csv file

# File 2: Food.csv
# This file will contain the Food ID, Food Name, Expiration Pantry, Expiration Fridge,and Expiration Freezer


import csv
import pandas as pd
import numpy as np


# open the input file
with open('PLU Parsing/input.csv', 'r') as csvfile:
    # create a reader object
    reader = csv.reader(csvfile, delimiter=',')
    # create a list of lists
    data = list(reader)

# create a list of unique food names
food_names = []
for row in data:
    if row[1] not in food_names:
        food_names.append(row[1])

# for every unique food name, create a list of PLU codes that reference that food name
# the key is the food name and the value is a list of PLU codes
food_dict = {}
for food in food_names:
    food_dict[food] = []
    for row in data:
        if row[1] == food:
            food_dict[food].append(row[0])


# we will start by creating the Food dataframe
# the Food ID will be the index of the food_names list
# the Food Name will be the food name
# the Expiration Pantry, Expiration Fridge,and Expiration Freezer will be set to 0 for now

# create a dataframe and label the columns
food_df = pd.DataFrame(columns=['Food ID', 'Food Name', 'Expiration Pantry', 'Expiration Fridge', 'Expiration Freezer'])
# create a list of lists that will be used to create the dataframe
food_list = []
# for every food name, create a list of the food ID, food name, and expiration dates
for food in food_names:
    food_list.append([food_names.index(food), food, 0, 0, 0])
# create the dataframe
food_df = pd.DataFrame(food_list, columns=['Food ID', 'Food Name', 'Expiration Pantry', 'Expiration Fridge', 'Expiration Freezer'])
# set the Food ID as the index
food_df.set_index('Food ID', inplace=True)

# add the food names to the dataframe
food_df['Food Name'] = food_names
# set the expiration dates to 0
food_df['Expiration Pantry'] = 0
food_df['Expiration Fridge'] = 0
food_df['Expiration Freezer'] = 0


# now we need to Add the exiration dates to the Food dataframe
# We need to load in the expiration dates from the Fruits.csv and Vegtables.csv files
# we will use the Food Name as the key to find the expiration dates
# to make sure we get the right item, we in the fruit.csv we need to search for the word "WHOLE" and make sure that the freezer, fridge, and pantry columns are populated
# in the vegtables.csv we need to search for the word "RAW" and "FRESH" 

# open the Fruits.csv file and read the information into a dataframe
# the first row is the header

# open the Fruits.csv file
fruit_df = pd.read_csv ('PLU Parsing/Expiration Data/Fruits.csv')
# add the column names
fruit_df.columns = ['Label','Link','Fridge','Freezer','Pantry']

# drop the columns that we do not need
fruit_df = fruit_df.drop(columns=['Link'])

# delete all the rows where the freezer, fridge, and pantry columns are empty
# so that we are left with only the rows that have all 3 expiration dates
fruit_df = fruit_df.dropna(subset=['Freezer', 'Fridge', 'Pantry'])

# delete all the rows where the Label does not contain the word "WHOLE"
fruit_df = fruit_df[fruit_df['Label'].str.contains("WHOLE")]

# # reset the index
fruit_df = fruit_df.reset_index(drop=True)


# open the Vegtables.csv file
veg_df = pd.read_csv ('PLU Parsing/Expiration Data/Vegetables.csv')
# add the column names
veg_df.columns = ['Label','Link','Fridge','Freezer','Pantry']

# drop the columns that we do not need
veg_df = veg_df.drop(columns=['Link'])

# search for the word "RAW" and "FRESH" in the Label column delete all the rows that do not contain Both these words in the Label
veg_df = veg_df[veg_df['Label'].str.contains("RAW")]
veg_df = veg_df[veg_df['Label'].str.contains("FRESH")]

# reset the index
veg_df = veg_df.reset_index(drop=True)

# combine the fruit and vegtables dataframes
expiration_df = pd.concat([fruit_df, veg_df], ignore_index=True)

# reset the index
expiration_df = expiration_df.reset_index(drop=True)

#export the expiration dataframe to a csv file
expiration_df.to_csv('PLU Parsing/Expiration Data/Expiration.csv', index=False)

# search the label column of the expiration dataframe for the food name in the food dataframe
# if the food name is found, add the expiration dates to the food dataframe to the appropriate column (freezer,fridge,pantry) 
# add a counter for each row that is found and print the percentage of rows that have been found at the end
counter = 0
for index, row in food_df.iterrows():
    for index2, row2 in expiration_df.iterrows():
        if row['Food Name'] in row2['Label']:
            food_df.at[index, 'Expiration Freezer'] = row2['Freezer']
            food_df.at[index, 'Expiration Fridge'] = row2['Fridge']
            food_df.at[index, 'Expiration Pantry'] = row2['Pantry']
            counter += 1

print(counter/len(food_df)*100)


# print the food dataframe
print(food_df)


# export the food dataframe to a csv file
food_df.to_csv('PLU Parsing/Output/Food.csv')

# now we need to create the PLU dataframe
# the PLU ID will be the index of the PLU codes
# the PLU Code will be the PLU code
# the Food ID will be the index of the food name in the food dataframe

# create a dataframe and label the columns
plu_df = pd.DataFrame(columns=['PLU ID', 'PLU Code', 'Food ID'])

# loop through the food_dict. For every food name in the food_dict, loop through the PLU codes that reference that food name
# for every PLU code, add a row to the dataframe with the PLU ID, PLU Code, and Food ID from the food dataframe
# the PLU ID will be the index of the PLU codes
# the PLU Code will be the PLU code
# the Food ID will be the index of the food name in the food dataframe

# create a list of lists that will be used to create the dataframe
plu_list = []
# for every food name in the food_dict


for food in food_dict:
    # loop through the PLU codes that reference that food name
    for index, plu in enumerate(food_dict[food]):
        # for every PLU code, add a row to the dataframe with the PLU ID, PLU Code, and Food ID from the food dataframe
        plu_list.append([0, plu, food_df.index[food_df['Food Name'] == food][0]])

# create the dataframe
plu_df = pd.DataFrame(plu_list, columns=['PLU ID', 'PLU Code', 'Food ID'])

# enumerate the PLU ID column
plu_df['PLU ID'] = plu_df.index


# export the plu dataframe to a csv file
plu_df.to_csv('PLU Parsing/Output/PLU.csv', index=False)


