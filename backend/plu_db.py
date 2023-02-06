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
engine = create_engine('sqlite://'+path+'pluDB.sqlite', echo=True)
# init "base" obj to manage tables (map classes to tables)
base = declarative_base()

# PLU class
class PLU(base):

    __tablename__ = 'plu_table'

    plu_id = Column(Integer, primary_key=True)
    plu_code = Column(Integer)
    food_id = Column(String)

    # constructor
    def __init__(self, plu_id, plu_code, food_id):
        self.plu_id = plu_id
        self.plu_code = plu_code
        self.food_id = food_id

# create tables in database
base.metadata.create_all(engine)

# new session
Session = sessionmaker(bind=engine)
s = Session()

# ref: https://stackoverflow.com/questions/31394998/using-sqlalchemy-to-load-csv-file-into-a-database
try:
    # load file
    file_name = os.getcwd() + "\\PLU Parsing\\Output\\PLU.csv"
    # read csv into dataframe
    df = pd.read_csv(file_name, on_bad_lines='skip', usecols=['PLU ID', 'PLU Code', 'Food ID'])
    # rename columns
    df.rename(columns={'PLU ID': 'plu_id', 'PLU Code': 'plu_code', 'Food ID': 'food_id'}, inplace=True)
    # convert dataframe to sql, connect to sqlalchemy db
    df.to_sql(PLU.__tablename__, con=engine,  if_exists='replace')
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

