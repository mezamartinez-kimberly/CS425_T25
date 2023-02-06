from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine
from sqlalchemy import Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
import pandas as pd

# debug
# import linecache
# import sys
# def PrintException():
#     exc_type, exc_obj, tb = sys.exc_info()
#     f = tb.tb_frame
#     lineno = tb.tb_lineno
#     filename = f.f_code.co_filename
#     linecache.checkcache(filename)
#     line = linecache.getline(filename, lineno, f.f_globals)
#     print(filename, lineno, line.strip(), exc_obj)


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
    file_name = os.getcwd() + "\\PLU Parsing\\Output\\PLU.csv"

    if(os.path.isfile(file_name)):
        print("file exists")
    else:
        print("file does not exist")
    # read csv into dataframe
    df = pd.read_csv(file_name, on_bad_lines='skip', usecols=['PLU ID', 'PLU Code', 'Food ID'])
    # rename columns
    df.rename(columns={'PLU ID': 'plu_id', 'PLU Code': 'plu_code', 'Food ID': 'food_id'}, inplace=True)
    # convert dataframe to sql, connect to sqlalchemy db
    df.to_sql(PLU.__tablename__, con=engine, index=True, index_label='index', if_exists='replace')
    # commit changes
    s.commit()

except:
    #PrintException()
    print(e)
    # rollback changes on error
    s.rollback() 
finally:
    # always close connection
    s.close() 

