# reference: https://pythonbasics.org/flask-sqlalchemy/

from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine, Column, Integer, String, JSON, Null
from sqlalchemy import null

import ssl # for handling ssl certificate error
import sys # for handling utf-8 encoding error when printing proudct name

# ref: https://stackoverflow.com/questions/27835619/urllib-and-ssl-certificate-verify-failed-error
try:
    _create_unverified_https_context = ssl._create_unverified_context
except AttributeError:
    # Legacy Python that doesn't verify HTTPS certificates by default
    pass
else:
    # Handle target environment that doesn't support HTTPS verification
    ssl._create_default_https_context = _create_unverified_https_context

# ref: https://stackoverflow.com/questions/27092833/unicodeencodeerror-charmap-codec-cant-encode-characters
sys.stdin.reconfigure(encoding='utf-8')
sys.stdout.reconfigure(encoding='utf-8')

# for API Calls
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError

import json
import csv

from datetime import datetime # for date formatting

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
        with open("Email Templates/forgotPassword.html", "r", encoding="utf-8") as file:
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
def deleteAll():
    # deltet the pantry table
    Pantry.query.delete()

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
# @jwt_required() # authentication Required
def upc(parameterUPC=None):

    if parameterUPC is None:
        # if we are using it as a route, we will get the upc from the json input
        upc = request.json['upc']
    else:
        # if we are using it as a function, we will get the upc from the parameter
        upc = parameterUPC

    # check to see if the upc is already in the database
    product = Product.query.filter_by(upc=upc).first()

    if product is None:
        # if the product is not in the database, query the API
        try:
            api_key = 'd20cfa73c6e8943592d96091a7469ccad33c7b60d59ab8a7923d0adc573bf5d8'

            req = Request('https://go-upc.com/api/v1/code/' + upc)
            req.add_header('Authorization', 'Bearer ' + api_key)

            content = urlopen(req).read()
            data = json.loads(content.decode())

            product_name = data["product"]["name"]
            

            # save data to a csv file located in the JSON Output Folder
            with open('JSON Output/UPC.csv', 'a', encoding="utf-8") as f:
                writer = csv.writer(f)
                writer.writerow([upc, data])

            # search to see if the product is already in the database
            product = Product.query.filter_by(upc=upc).first()

        
        # All the possible errors:
        except HTTPError as e:
            print(e)
            return jsonify({'error': f'HTTP error: {e.code} {e.reason}'}), 500
        except URLError as e:
            print(e)
            return jsonify({'error': f'URL error: {e.reason}'}), 500
        except (KeyError, TypeError) as e:
            print(e)
            return jsonify({'error': 'Invalid UPC code or API response'}), 400
        except Exception as e:
            print(e)
            return jsonify({'error': f'Unexpected error: {str(e)}'}), 500
    else:
        # if the product is in the database, return the name
        product_name = product.name
        return jsonify({'message': 'UPC API call successful', 'name': product_name}), 200
    

@app.route('/addPantry', methods=['POST'])
@jwt_required() # authentication Required
def addPantry():
    # expected input:
    # {
    #     "name": "Apple",
    #     "date_added": "2020-01-01",
    #     "location": "pantry",
    #     "upc": "123456789012",
    #     "plu": "1",
    #    "quantity": "1"
    # }

    name = request.json['name']
    date_added = request.json['date_added']
    location = request.json['location']
    parameterUPC = request.json['upc']
    parameterUPC = str(parameterUPC)
    plu = request.json['plu']
    quantity = request.json['quantity']

    # print the type and content of each variable

    # get the session token from the authorization html header
    session_token = request.headers.get('Authorization').split()[1]
    # get the user id from the session token
    user_id = User.query.filter_by(session_token=session_token).first().id
    
    # Seach for the UPC or PLU in the database, depending on which one is not null, to get the product id
    # if on search there is no upc found then we will add the product to the database via the upc api
    if parameterUPC:

        print(parameterUPC)

        # query the product table to see if a product with the upc exists, if yes get the product id ONLLY of the first match
        product = Product.query.filter_by(upc=parameterUPC).first()

        if not product:
            # call the upc route function
            product = Product.query.filter_by(upc=parameterUPC).first()

    elif plu:
        product = Product.query.filter_by(plu=plu).first()
        if not product:
            return jsonify({'error': 'PLU not found'}), 404
    else:
        return jsonify({'error': 'No UPC or PLU provided'}), 400

    
    # convert the date_added string to a datetime object
    date_added = datetime.strptime(date_added, '%Y-%m-%d %H:%M:%S.%f')

    print(product)

    # ok so by here we have the plu or upc and the product id, as well as the date created
    # now we need to add the product to the pantry
    pantry = Pantry(user_id=user_id,
                    product_id=product.id,
                    date_added=date_added,
                    date_removed=None,
                    # if the location is not provided, we will default it to pantry
                    location=location if location else 'pantry',
                    quantity=quantity,
                    is_deleted=False)
    
    db.session.add(pantry)
    db.session.commit()

    return jsonify({'message': 'Pantry item added successfully'}), 201

@app.route('/getAllPantry', methods=['GET'])
@jwt_required() # authentication Required
def getAllPantry():
    # get the session token from the authorization html header
    session_token = request.headers.get('Authorization').split()[1]

    # get the user id from the session token
    user_id = User.query.filter_by(session_token=session_token).first().id

    # get all the pantry items for the user
    pantry = Pantry.query.filter_by(user_id=user_id).all()

    # check to see if the user has any pantry items
    if not pantry:
        return jsonify({'error': 'No pantry items found'}), 401
    else:
        # create a list of pantry items
        pantry_list = []

        # loop through each pantry item
        for item in pantry:
            # get the product details
            product = Product.query.filter_by(id=item.product_id).first()

            # search the expiration table for the product for the product id
            expiration = ExpirationData.query.filter_by(product_id=item.product_id).first()

            if expiration != None:
                # where is the food stored?
                if item.location == 'pantry' and expiration.expiration_time_pantry != None:
                    expiration_date = item.date_added + datetime(days=expiration.expiration_time_pantry)
                elif item.location == 'fridge' and expiration.expiration_time_fridge != None:
                    expiration_date = item.date_added + datetime(days=expiration.expiration_time_fridge)
                elif item.location == 'freezer' and expiration.expiration_time_freezer != None:
                    expiration_date = item.date_added + datetime(days=expiration.expiration_time_freezer)
            else:
                expiration_date = None


            if item.location == 'pantry':
                location = 1
            elif item.location == 'fridge':
                location = 2
            elif item.location == 'freezer':
                location = 3
            else:
                location = 0
    
            # create a dictionary of the pantry item details
            pantry_item = {
                'id': item.id,
                'name': product.name,
                # if none type then return null
                'date_added': item.date_added.isoformat() if item.date_added else None,
                'date_removed': item.date_removed.isoformat() if item.date_removed else None,
                'location': location,
                'quantity': item.quantity,
                'expiration_date': expiration_date.isoformat() if expiration_date else None,
                'is_deleted': int(item.is_deleted)
            }

            # add the dictionary to the list
            pantry_list.append(pantry_item)

        # return the list of pantry items
        return jsonify(pantry_list), 200


# create a route to update an item in the pantry
@app.route('/updatePantryItem', methods=['POST'])
@jwt_required() # authentication Required
def updatePantryItem():
# expected input:
# {
#     "id": "1",
#     "name": "Apple",
#     "date_added": "",
#     "date_removed": "",
#     "expiration_date": "2020-01-01"
#     "quantity": "1"
#     "location": "pantry",
#     "upc": "123456789012",
#     "plu": "1",
#     "expiration_date": "2020-01-01"
#    "is_deleted": "0"
# }


    # get the session token from the authorization html header
    session_token = request.headers.get('Authorization').split()[1]
    
    # get the user id from the session token
    user_id = User.query.filter_by(session_token=session_token).first().id

    # get the id of the pantry item to update
    id = request.json['id']

    # get the pantry item to update
    pantry = Pantry.query.filter_by(id=id).first()

    # check to see if the pantry item exists
    if not pantry:
        return jsonify({'error': 'Pantry item not found'}), 404
    else:
        # get the product details
        product = Product.query.filter_by(id=pantry.product_id).first()

        # get the expiration details
        expiration = ExpirationData.query.filter_by(product_id=pantry.product_id).first()

        # now add the new information to the pantry item/ product/ expiration if not Null/None
        if request.json['name']:
            product.name = request.json['name']
        if request.json['date_added']:

            # convert the date ISO8601 format to a datetime object
            date_added = datetime.strptime(request.json['date_added'], '%Y-%m-%dT%H:%M:%S.%f')

            pantry.date_added = date_added
        if request.json['date_removed']:
            # convert the date ISO8601 format to a datetime object
            date_removed = datetime.strptime(request.json['date_removed'], '%Y-%m-%dT%H:%M:%S.%f')

            pantry.date_removed = date_removed
        if request.json['location']:
            if request.json['location'] == '1':
                location = "pantry"
            elif request.json['location'] == '2':
                location = "fridge"
            elif request.json['location'] == '3':
                location = "freezer"
            else:
                location = "pantry"
        if request.json['upc']:
            product.upc = request.json['upc']
        if request.json['plu']:
            product.plu = request.json['plu']
        if request.json['expiration_date']:
            
            # convert the date ISO8601 format to a datetime object
            expiration_date = datetime.strptime(request.json['expiration_date'], '%Y-%m-%dT%H:%M:%S.%f')
    
            if location == 'pantry':
                # calculate the difference between date adeed and expiration date
                expiration.expiration_time_pantry = (expiration_date - pantry.date_added).days
            elif location == 'fridge':
                # calculate the difference between date adeed and expiration date
                expiration.expiration_time_fridge = (expiration_date - pantry.date_added).days
            elif location == 'freezer':
                # calculate the difference between date adeed and expiration date
                expiration.expiration_time_freezer = (expiration_date - pantry.date_added).days
        if request.json['quantity']:
            pantry.quantity = request.json['quantity']
        if request.json['is_deleted']:
            pantry.is_deleted = request.json['is_deleted']

        # add the changes to the pantry item/ product/ expiration if not Null/None
        if pantry != None:
            db.session.add(pantry)
        if product != None:
            db.session.add(product)
        if expiration != None:
            db.session.add(expiration)

        # commit the changes to the database
        db.session.commit()

        return jsonify({'message': 'Pantry item updated successfully'}), 201
    

        

