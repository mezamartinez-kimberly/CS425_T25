# reference: https://pythonbasics.org/flask-sqlalchemy/

from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine, Column, Integer, String, JSON, Null
from sqlalchemy import null

# for API Calls
from urllib.request import Request, urlopen
import json

# create Json Web Token (JWT) for authentication
from flask_jwt_extended import create_access_token
from flask_jwt_extended import get_jwt_identity
from flask_jwt_extended import jwt_required
from flask_jwt_extended import JWTManager


# password hashing
from flask_bcrypt import Bcrypt

# Import the database object and the Model Classes from the models.py file
from models import db, User, UserPreference, Person



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


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SETUP ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# create the flask app
app = Flask(__name__)
bcrypt = Bcrypt(app)
jwt = JWTManager(app)


# set the token to never expire ~ this is for testing purposes
JWT_ACCESS_TOKEN_EXPIRES = False

# tells SQLAlchemy where the database is
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///db.sqlite'
# create a super secret key for JWT
app.config["JWT_SECRET_KEY"] = "eyJhbGciOiJIUzI1NiJ9.eyJSb2xlIjoiQWRtaW4iLCJJc3N1ZXIiOiJJc3N1ZXIiLCJVc2VybmFtZSI6IkphdmFJblVzZSIsImV4cCI6MTY3NjQ5MzAyOSwiaWF0IjoxNjc2NDkzMDI5fQ.Oa-YzeYO8bLEqSKb3nJ6wm7n7z9mJP7Qc2zVc3qjY3k"  

db.init_app(app)




# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SETUP END ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# ~~~~~~~~~~~~~~~~~~~~~~~~~~ ROUTE SETUP ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@app.route('/register', methods=['POST'])
# expected input:
# {
#     "first_name": "John",
#     "last_name": "Doe",
#     "email": "johndoe123@gmail.com",
#     "password": "password123"
# }
def register():
    first_name = request.json['first_name']
    last_name = request.json['last_name']
    email = request.json['email']
    password = request.json['password']

    # Check if the email is already registered
    if User.query.filter_by(email=email).first():
        return jsonify({'error': 'Email already registered'}, 401)

    # Create a new user and user preference
    person = Person(first_name=first_name, 
                    last_name=last_name, 
                    alias=None)
    
    user_preference = UserPreference(is_first_login=True, 
                                     leaderboard_points=0, 
                                     is_dark_mode=False,
                                     is_notifications_on=True, 
                                     notification_range=10)
    
    db.session.add(person)
    db.session.add(user_preference)
    db.session.commit()


    # we do it in this order so that we can grab the id of the person and user_preference
    user = User(person_id=person.id,
            user_preference_id=user_preference.id, 
            email=email, 
            password=bcrypt.generate_password_hash(password).decode('utf-8'),
            username=None, 
            session_token=None)

    db.session.add(user)
    db.session.commit()

    return jsonify({'message': 'User created successfully'}), 201


@app.route('/login', methods=['POST'])
# expected input:
# {
#     "email": "
#     "password": "
# }
def login():
    email = request.json['email']
    password = request.json['password']


    # Note: The message "Please check your credentials and try again" is used to prevent
    # malicious users from knowing which field is incorrect

    # Check if the email is registered
    user = User.query.filter_by(email=email).first()
    if not user:
        print ("email not registered")
        print (email)
        return jsonify({'error': 'Please check your credentials and try again'}), 401
    

    # Check if the password is correct
    if not bcrypt.check_password_hash(user.password_hash, password):
        print ("password is incorrect")
        return jsonify({'error': 'Please check your credentials and try again'}), 401

    # Generate a session token
    session_token = create_access_token(identity=email)

    # Update the user's session token
    user.session_token = session_token
    db.session.add(user)
    db.session.commit()

    return jsonify({'message': 'User logged in successfully', 'session_token': session_token}), 201



# create a quick debug route that will delete all info from all tables
@app.route('/delete_all', methods=['DELETE'])
def delete_all():
    db.session.query(User).delete()
    db.session.query(UserPreference).delete()
    db.session.query(Person).delete()
    db.session.commit()
    return jsonify({'message': 'All tables have been cleared'}), 200


# create a route that will query the upc API and return the data
@app.route('/upc', methods=['GET'])
# expected input:
# {
#     "upc": ""
#     "session_token": ""
# }
#@jwt_required# this means that the session token must be passed in the header
def upc():
    upc = request.json['upc']
    api_key = 'd20cfa73c6e8943592d96091a7469ccad33c7b60d59ab8a7923d0adc573bf5d8'

    req = Request('https://go-upc.com/api/v1/code/' + upc)
    req.add_header('Authorization', 'Bearer ' + api_key)
    
    content = urlopen(req).read()
    data = json.loads(content.decode())

    product_name = data["product"]["name"]


    return jsonify({'message': 'UPC API call successful', 'name': product_name }), 200
