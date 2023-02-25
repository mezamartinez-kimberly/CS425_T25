# NOTE: the input file: "input.csv" has 3 columns of data, the first column is the PLU Code, the second column is the genral Food Name, and the third column is the specific Food Name

# the data looks like this:
# 3003,Apples,D'Estivale Apples

# for parsing the infomation we're assuming that all Foods generally expire under the same time frame,
# for instance all apples expire more or less around the same time


import csv
import pandas as pd
import numpy as np



# read the csv file
df = pd.read_csv('input.csv', header=None)

# create a new column for the expiration date for pantry, fridge and freezer
df['Pantry'] = np.nan
df['Fridge'] = np.nan
df['Freezer'] = np.nan


# create