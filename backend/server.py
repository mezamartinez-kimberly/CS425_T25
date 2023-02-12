# reference: https://pythonbasics.org/flask-sqlalchemy/

from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine, Column, Integer, String, JSON, Null
from sqlalchemy import null


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# how to create the virtual environment/ install flask & dotenv
# https://flask.palletsprojects.com/en/2.2.x/installation/#virtual-environments

# launch the virtual environment (cd into the backend folder first)
# . venv/bin/activate 
# you should see (venv) in front of your terminal prompt

# !!!!!!! REMEMBER TO ADD YOUR VENV FOLDER TO YOUR .gitignore FILE !!!!!!!!

# how to run the server
# flask --app server run

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~~~~~ DATABASE SETUP ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

db = SQLAlchemy()

# create the flask app
app = Flask(__name__)

# tells SQLAlchemy where the database is
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///db.sqlite'

db.init_app(app)

# Define the User Database Class
class User(db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True)
    person_id = db.Column(db.Integer, db.ForeignKey('person.id'), unique=True)
    user_preference_id = db.Column(db.Integer, db.ForeignKey('user_preference.id'), unique=True)
    username = db.Column(db.String(80), nullable=False)
    password = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(120), nullable=False)
    session_token = db.Column(db.String(120), nullable=True)

    # one-to-one relationship with the Person table
    person = db.relationship('Person', uselist=False, back_populates='user')
    # one-to-one relationship with the UserPreference table
    user_preference = db.relationship('UserPreference', uselist=False, back_populates='user')
    # one-to-many realtionship with the ExpirationData table
    expiration_data = db.relationship('ExpirationData', backref='user', lazy=True)

    # define the constructor
    def __init__(self, person_id, user_preference_id, username, password, email, session_token):
        self.person_id = person_id
        self.user_preference_id = user_preference_id
        self.username = username
        self.password = password
        self.email = email
        self.session_token = session_token

# Define the UserPreference Database Class
class UserPreference(db.Model):
    __tablename__ = 'user_preference'
    id = db.Column(db.Integer, primary_key=True)
    is_first_login = db.Column(db.Boolean, nullable=False)
    leaderboard_points = db.Column(db.Integer, nullable=False)
    is_dark_mode = db.Column(db.Boolean, nullable=False)
    is_notifications_on = db.Column(db.Boolean, nullable=False)
    notification_range = db.Column(db.Integer, nullable=False)

    # one-to-one relationship with the User table
    user = db.relationship('User', uselist=False, back_populates='user_preference')
    
    # define the constructor
    def __init__(self, is_first_login, leaderboard_points, is_dark_mode, is_notifications_on, notification_range):
        self.is_first_login = is_first_login
        self.leaderboard_points = leaderboard_points
        self.is_dark_mode = is_dark_mode
        self.is_notifications_on = is_notifications_on
        self.notification_range = notification_range

# Define the Person Database Class
class Person(db.Model):
    __tablename__ = 'person'
    id = db.Column(db.Integer, primary_key=True)
    first_name = db.Column(db.String(30), nullable=False)
    last_name = db.Column(db.String(30), nullable=False)
    alias = db.Column(db.String(30), nullable=True)

    # one-to-one relationship with the User table
    user = db.relationship('User', uselist=False, back_populates='person')

    # define the constructor
    def __init__(self, first_name, last_name, alias):
        self.first_name = first_name
        self.last_name = last_name
        self.alias = alias

# Define the Product Database Class
class Product(db.Model):
    __tablename__ = 'product'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(300), nullable=False)
    upc = db.Column(db.String(12), nullable=True)
    plu = db.Column(db.String(5), nullable=True)
    logical_delete = db.Column(db.Boolean, nullable=False)

    # one-to-many relationship with the ExpirationData table
    expiration_data = db.relationship('ExpirationData', backref='product', lazy=True)

    # define the constructor
    def __init__(self, name, upc, plu, logical_delete):
        self.name = name
        self.upc = upc
        self.plu = plu
        self.logical_delete = logical_delete

# Define the ExpirationData Database Class
class ExpirationData(db.Model):
    __tablename__ = 'expiration_data'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    product_id = db.Column(db.Integer, db.ForeignKey('product.id'), nullable=False)
    expiration_time_pantry = db.Column(db.Integer, nullable=True)
    expiration_time_fridge = db.Column(db.Integer, nullable=True)
    expiration_time_freezer = db.Column(db.Integer, nullable=True)
    

    #define the relationship with the User table
    user = db.relationship('User', backref='expiration_data', lazy=True)
    #define the relationship with the Product table
    product = db.relationship('Product', backref='expiration_data', lazy=True)


    # define the constructor
    def __init__(self, user_id, product_id, expiration_time_pantry, expiration_time_fridge, expiration_time_freezer):
        self.user_id = user_id
        self.product_id = product_id
        self.expiration_time_pantry = expiration_time_pantry
        self.expiration_time_fridge = expiration_time_fridge
        self.expiration_time_freezer = expiration_time_freezer


# ~~~~~~~~~~~~~~~~~~~~~~~~~~ END OF DATABASE SETUP ~~~~~~~~~~~~~~~~~~~~~~~~~


# ~~~~~~~~~~~~~~~~~~~~~~~~~~ ROUTE SETUP ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# API route to get add a product to the database
@app.route('/crowdsource/add', methods=['POST'])
#  ~~ Expected Input ~~
#  {
#    "name": "string",
#    "upc": "string",
#    "plu": "string",
#    "expiration_time": "integer",
#    "food_location": "string",
#    "user_id": "integer",
#    "session_token": 'string'
#  }
def crowd_source_add():
    if request.method == 'POST':
        # get the data from the request
        data = request.get_json()

        # check the session token given in the request against the entry in the User table
        user = User.query.filter_by(session_token=data['session_token']).first()







    return jsonify({'message': 'Product added successfully'})


