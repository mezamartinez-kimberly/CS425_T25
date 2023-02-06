from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine
from sqlalchemy import Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
import pandas as pd

# ref: https://www.youtube.com/watch?v=NuDSWGOcvtg

# create and connect to database
path = '/backend/'
engine = create_engine('sqlite://'+path+'foodDB.sqlite', echo=True)
# init "base" obj to manage tables (map classes to tables)
base = declarative_base()

# Food class
class Food(base):

    __tablename__ = 'food_table'

    food_id = Column(String, primary_key=True)
    food_name = Column(String)
    expiration_pantry = Column(Integer)
    expiration_fridge = Column(Integer)
    expiration_freezer = Column(Integer)


    # constructor
    def __init__(self, food_id, food_name, expiration_pantry, expiration_fridge, expiration_freezer):
        self.food_id = food_id
        self.food_name = food_name
        self.expiration_pantry = expiration_pantry
        self.expiration_fridge = expiration_fridge
        self.expiration_freezer = expiration_freezer

# create tables in database
base.metadata.create_all(engine)

# new session
Session = sessionmaker(bind=engine)
s = Session()

# ref: https://stackoverflow.com/questions/31394998/using-sqlalchemy-to-load-csv-file-into-a-database
try:
    # load file
    file_name = os.getcwd() + "\\PLU Parsing\\Output\\Food.csv"
    # read csv into dataframe
    df = pd.read_csv(file_name, on_bad_lines='skip', usecols=['Food ID','Food Name','Expiration Pantry','Expiration Fridge','Expiration Freezer'])
    # rename columns
    df.rename(columns={'Food ID': 'food_id', 'Food Name': 'food_name','Expiration Pantry': 'expiration_pantry','Expiration Fridge': 'expiration_fridge','Expiration Freezer': 'expiration_freezer'}, inplace=True)
    # convert dataframe to sql, connect to sqlalchemy db
    df.to_sql(Food.__tablename__, con=engine, index=False, if_exists='replace')
    # commit changes
    s.commit()

except:
    print(e)
    # rollback changes on error
    s.rollback() 
finally:
    # always close connection
    s.close() 

