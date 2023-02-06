# ref: https://stackoverflow.com/questions/31394998/using-sqlalchemy-to-load-csv-file-into-a-database

import db # my db file
import os
import pandas
from sqlalchemy.orm import sessionmaker

# new session
Session = sessionmaker(bind=db.engine)
s = Session()

try:
    # load file
    file_name = os.path.split(os.getcwd())[0] + "\\CS425_T25\\PLU Parsing\\input.csv"
    # read csv into dataframe
    df = pandas.read_csv(file_name, on_bad_lines='skip', usecols=['PLU', 'Food Name'])
    # rename columns
    df.rename(columns={'PLU': 'plu_code', 'Food Name': 'food_name'}, inplace=True)
    # convert dataframe to sql, connect to sqlalchemy db
    df.to_sql(db.PLU.__tablename__, con=db.engine, index=True, index_label='index', if_exists='replace')
    # commit changes
    s.commit()
except Exception as e:
    print(e)
    # rollback changes on error
    s.rollback() 
finally:
    # always close connection
    s.close() 

