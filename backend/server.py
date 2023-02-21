# reference: https://pythonbasics.org/flask-sqlalchemy/

from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine, Column, Integer, String, JSON, Null
from sqlalchemy import null

# for API Calls
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError

import json

# create Json Web Token (JWT) for authentication
from flask_jwt_extended import create_access_token
from flask_jwt_extended import get_jwt_identity
from flask_jwt_extended import jwt_required
from flask_jwt_extended import JWTManager

# for confimation emails
from flask_mail import Mail, Message

# password hashing
from flask_bcrypt import Bcrypt
import bs4 # for html/ email editing
import random # for generating random numbers for OTP


# Import the database object and the Model Classes from the models.py file
from models import db, User, UserPreference, Person, Product, ExpirationData, Pantry

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
mail = Mail(app) 


# set the token to never expire ~ this is for testing purposes
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = False
# tells SQLAlchemy where the database is
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///db.sqlite'
# create a super secret key for JWT
app.config["JWT_SECRET_KEY"] = "eyJhbGciOiJIUzI1NiJ9.eyJSb2xlIjoiQWRtaW4iLCJJc3N1ZXIiOiJJc3N1ZXIiLCJVc2VybmFtZSI6IkphdmFJblVzZSIsImV4cCI6MTY3NjQ5MzAyOSwiaWF0IjoxNjc2NDkzMDI5fQ.Oa-YzeYO8bLEqSKb3nJ6wm7n7z9mJP7Qc2zVc3qjY3k"  

# configuration of mail
app.config['MAIL_SERVER']='smtp.gmail.com'
app.config['MAIL_PORT'] = 465
app.config['MAIL_USERNAME'] = 'edna.app123@gmail.com'
app.config['MAIL_PASSWORD'] = 'zjmlopzqglasobnc'
app.config['MAIL_USE_TLS'] = False
app.config['MAIL_USE_SSL'] = True
mail = Mail(app)

db.init_app(app)

time_confimation_otp_was_sent = 0


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SETUP END ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# ~~~~~~~~~~~~~~~~~~~~~~~~~~ ROUTE SETUP ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

@app.route("/sendOTP", methods=["POST"])
def sendOTP():

    # expected input:
    # {
    #          "email": "
    # }

    # parse the json input
    email = request.json['email']

    print(email)


    # check if the email is registered
    user = User.query.filter_by(email=email).first()

    if user is None:
        return jsonify({'error': 'Email not registered'}), 401
    else:
        # generate a random 5 digit number
        otp = random.randint(10000, 99999)

        # check if the user is trying to reset their password or confirm their email
            #import the html file and replace the otp with the generated otp
        with open("Email Templates/forgotPassword.html", "r") as file:
            html = file.read()
            html = html.replace("98273", str(otp))
        
        # send the email
        msg = Message('Edna - Forgot Password', sender = 'yourId@gmail.com', recipients = [email])
        msg.html = html
        mail.send(msg)

        # update the user's otp and hash using bcrypt
        user.otp_hash = bcrypt.generate_password_hash(str(otp)).decode('utf-8')
        db.session.commit()

        return jsonify({'message': 'OTP sent successfully'}),201




# create an approute to verify the otp
@app.route("/verifyOTP", methods=["POST"])
def verifyOTP():
    
        # expected input:
        # {
        #     "email": "email",
        #     "otp": "otp"
        # }
    
        # parse the json input
        email = request.json['email']
        otp = request.json['otp']


        # check if the email is registered
        user = User.query.filter_by(email=email).first()

        if user is None:
            return jsonify({'error': 'Email not registered'}), 401
        else:
            # check if the otp is correct
            if bcrypt.check_password_hash(user.otp_hash, otp):
                return jsonify({'message': 'OTP is correct'}), 200
            else:
                return jsonify({'error': 'OTP is incorrect'}), 402
            

@app.route("/changPassword", methods=["POST"])
def resetPassword():
        
            # expected input:
            # {
            #     "email": "email",
            #     "password": "password"
            # }
        
            # parse the json input
            email = request.json['email']
            password = request.json['password']
    
            # check if the email is registered
            user = User.query.filter_by(email=email).first()
    
            # check to see if the new password is different from the old password
            if bcrypt.check_password_hash(user.password_hash, password):
                return jsonify({'error': 'New password cannot be the same as the old password'}), 401
            else:
                # update the user's password
                user.password_hash = bcrypt.generate_password_hash(password).decode('utf-8')
                db.session.commit()

                return jsonify({'message': 'Password updated successfully'}), 200




# create a quick debug route that will delete all info from all tables
@app.route('/delete_all', methods=['DELETE'])
def delete_all():
    db.session.query(User).delete()
    db.session.query(UserPreference).delete()
    db.session.query(Person).delete()
    db.session.commit()
    return jsonify({'message': 'All tables have been cleared'}), 200

@app.route('/register', methods=['POST'])
def register():

    # expected input:
    # {
    #     "first_name": "John",
    #     "last_name": "Doe",
    #     "email": "johndoe123@gmail.com",
    #     "password": "password123"
    # }

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
def login():
    # expected input:
    # {
    #     "email": "
    #     "password": "
    # }
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

# create a route that will query the upc API and return the data
@app.route('/upc', methods=['POST'])
@jwt_required()
def upc():
    try:
        upc = request.json['upc']
        api_key = 'd20cfa73c6e8943592d96091a7469ccad33c7b60d59ab8a7923d0adc573bf5d8'

        req = Request('https://go-upc.com/api/v1/code/' + upc)
        req.add_header('Authorization', 'Bearer ' + api_key)

        content = urlopen(req).read()
        data = json.loads(content.decode())

        product_name = data["product"]["name"]

        product = Product(upc=upc, name=product_name, logical_delete=0, plu=None)
        db.session.add(product)
        db.session.commit()

        return jsonify({'message': 'UPC API call successful', 'name': product_name}), 200
    
    # All the possible errors:
    except HTTPError as e:
        return jsonify({'error': f'HTTP error: {e.code} {e.reason}'}), 500
    except URLError as e:
        return jsonify({'error': f'URL error: {e.reason}'}), 500
    except (KeyError, TypeError) as e:
        return jsonify({'error': 'Invalid UPC code or API response'}), 400
    except Exception as e:
        return jsonify({'error': f'Unexpected error: {str(e)}'}), 500

# @app.route('/forgotPassword', methods=['POST'])
# def forgot_password():
