import db # my db file
from sqlalchemy.orm import sessionmaker

# new session
Session = sessionmaker(bind=db.engine)
s = Session()

# select data
for s in s.query(db.PLU).filter(db.PLU.plu_code == 4225): # AVOCADOS
    print(s.food_name)