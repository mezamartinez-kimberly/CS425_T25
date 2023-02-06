# ref: https://www.youtube.com/watch?v=NuDSWGOcvtg
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine
from sqlalchemy import Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# create and connect to database
engine = create_engine('sqlite:///pluDB.sqlite', echo=True)
# init "base" obj to manage tables (map classes to tables)
base = declarative_base()

# PLU class
class PLU(base):

    __tablename__ = 'plu'

    plu_code = Column(Integer, primary_key=True)
    food_name = Column(String)

    # constructor
    def __init__(self, plu_code, food_name):
        self.plu_code = plu_code
        self.food_name = food_name

# create tables in database
base.metadata.create_all(engine)