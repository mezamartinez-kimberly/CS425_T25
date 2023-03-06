# NOTE: the input file: "input.csv" has 3 columns of data, the first column is the PLU Code, the second column is the general Food Name, and the third column is the specific Food Name

# the data looks like this:
# 3003,Apples,D'Estivale Apples

# for parsing the infomation we're assuming that all Foods generally expire under the same time frame,
# for instance all types of apples expire more or less around the same time

import csv
import pandas as pd
import numpy as np



# read csv file into a dataframe and specify the column dtypes
input_df = pd.read_csv('PLU Parsing/input.csv', header=None)

# asign the column names
input_df.columns = ['PLU', 'Food', 'Specific Food']

# create a new column for the expiration date for pantry, fridge and freezer
input_df['Pantry'] = np.nan
input_df['Fridge'] = np.nan
input_df['Freezer'] = np.nan

# specify the data types for the columns
input_df['PLU'] = input_df['PLU'].astype(str)
input_df['Food'] = input_df['Food'].astype(str)
input_df['Specific Food'] = input_df['Specific Food'].astype(str)
input_df['Pantry'] = input_df['Pantry'].astype(str)
input_df['Fridge'] = input_df['Fridge'].astype(str)
input_df['Freezer'] = input_df['Freezer'].astype(str)


# read in the expiration data from the csv file
exp_df = pd.read_csv('PLU Parsing/Expiration Data/expiration_info.csv', header=None)

# asign the column names
exp_df.columns = ['Name', 'Fridge', 'Freezer', 'Pantry']

# specify the data types for the columns
exp_df['Name'] = exp_df['Name'].astype(str)
exp_df['Fridge'] = exp_df['Fridge'].astype(str)
exp_df['Freezer'] = exp_df['Freezer'].astype(str)
exp_df['Pantry'] = exp_df['Pantry'].astype(str)


# normalize the input data by lowercasing and stripping the strings in the name column of exp_df and the food column of input_df
exp_df['Name'] = exp_df['Name'].str.lower()
exp_df['Name'] = exp_df['Name'].str.strip()
input_df['Food'] = input_df['Food'].str.lower()
input_df['Food'] = input_df['Food'].str.strip()

# calcilate the total number of matches
total_matches = 0

# iterate through the input dataframe and assign the expiration dates
for index, row in input_df.iterrows():
    if index != 0:
        #print a progress bar
        print('Progress: ' + str(index) + '/' + str(len(input_df)))

        # get the food name
        food_name = row['Food']
        # get the expiration data for the food
        expiration_data = exp_df.loc[exp_df['Name'] == food_name]


        # get the specific food name
        specific_food_name = row['Specific Food']
        # get the expiration data for the specific food
        specific_expiration_data = exp_df.loc[exp_df['Name'] == specific_food_name]

        # if specific_expiration_data is not empty
        if not specific_expiration_data.empty:

            total_matches += 1
            # get the expiration data for the pantry
            pantry_exp = specific_expiration_data['Pantry'].values[0]
            # get the expiration data for the fridge
            fridge_exp = specific_expiration_data['Fridge'].values[0]
            # get the expiration data for the freezer
            freezer_exp = specific_expiration_data['Freezer'].values[0]

        elif not expiration_data.empty:
            total_matches += 1
            # get the expiration data for the pantry
            pantry_exp = expiration_data['Pantry'].values[0]
            # get the expiration data for the fridge
            fridge_exp = expiration_data['Fridge'].values[0]
            # get the expiration data for the freezer
            freezer_exp = expiration_data['Freezer'].values[0]
        else:
            # if the expiration data is not found, set the expiration data to nan
            pantry_exp = np.nan
            fridge_exp = np.nan
            freezer_exp = np.nan
        
        # assign the expiration data to the input dataframe
        input_df.at[index, 'Pantry'] = pantry_exp
        input_df.at[index, 'Fridge'] = fridge_exp
        input_df.at[index, 'Freezer'] = freezer_exp


print('Total Matches: ' + str(total_matches/(len(input_df)-300)) + '%')

# write the dataframe to a csv file
input_df.to_csv('PLU Parsing/Output/output.csv', index=False)
