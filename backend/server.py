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

from datetime import datetime, timedelta # for date formatting

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
from models import db, User, UserPreference, Person, Product, ExpirationData, Pantry, Alias

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

# lets create a route to load the the Product table with PLU data from a csv file
@app.route("/loadPLU", methods=["GET"])
def loadPLU():
    # open the csv file "PLU with Exp.csv"
    with open("PLU with Exp.csv", "r") as file:
        # create a csv reader
        reader = csv.reader(file)
        # skip the first row
        next(reader)
        # iterate through the rows
        for row in reader:
            # create a new product object
            product = Product(name = row[1], 
                              plu = row[0], 
                              logical_delete=False, 
                              upc=None)

            db.session.add(product)
            db.session.commit()

            # query the database to get the product id
            product = Product.query.filter_by(plu=row[0]).first()

            # create a new expiration data object
            expirationData = ExpirationData(product_id=product.id, 
                                            user_id=-1,
                                            expiration_time_pantry=row[2], 
                                            expiration_time_fridge=row[3], 
                                            expiration_time_freezer=row[4])

            # commit expiration data to the database
            db.session.add(expirationData)
            db.session.commit()

    return jsonify({'message': 'PLU data loaded'}), 200

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
    # # delete the pantry table
    # Product.query.delete()
    #delete the pantry table
    Pantry.query.delete()

    # delete user and person table
    # User.query.delete()
    # Person.query.delete()


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


def apiCall(upc):

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

            # return the data as a tuple with the first item being the data and the second being the error code
            return (product_name, 200)
        

        # account for all possible errors and 
        # return the error message as a tuple with the 
        # first item being the string message and the 
        # econd being the error code
        except HTTPError as e:
            return (str(e), 400)
        except URLError as e:
            return (str(e), 400)
        except ValueError as e:
            return (str(e), 400)
        except KeyError as e:
            return (str(e), 400)
        except Exception as e:
            return (str(e), 400)


# create a route that will query the upc API and return the data
@app.route('/upc', methods=['POST'])
# @jwt_required() # authentication Required
def upc():
    
    # if we are using it as a route, we will get the upc from the json input
    upc = request.json['upc']

    # check to see if the upc is already in the database
    product = Product.query.filter_by(upc=upc).first()

    # if its not in the database, query the API
    if product is None:
        response_tuple = apiCall(upc)

        # if the API call was successful, save the data to the database
        if response_tuple[1] == 200:
            product = Product(name=response_tuple[0], upc=upc, plu=None, logical_delete=False)
            db.session.add(product)
            db.session.commit()
            return jsonify({'message': 'UPC API call successful', 'name': response_tuple[0]}), 200
        else:
            return jsonify({'error': response_tuple[0]}), response_tuple[1]
    else:
    # if the product is in the database, return the name
        product_name = product.name
        return jsonify({'message': 'UPC API call successful', 'name': product_name}), 200
   

@app.route('/addPantry', methods=['POST'])
@jwt_required() # authentication Required
def addPantry():
    # expected input:
    # {
    #    "id": "1",
    #     "name": "Apple",
    #     "date_added": "2020-01-01",
    #     "expiration_date": "2020-01-01",
    #     "location": "pantry",
    #     "upc": "123456789012",
    #     "plu": "1",
    #    "quantity": "1"
    # }

    print(request.json)

    name = request.json['name']
    location = request.json['location']
    parameterUPC = request.json['upc']
    parameterUPC = str(parameterUPC)
    plu = request.json['plu']
    quantity = request.json['quantity']


    # get the session token from the authorization html header
    session_token = request.headers.get('Authorization').split()[1]
    # get the user id from the session token
    user_id = User.query.filter_by(session_token=session_token).first().id
    
    # Seach for the UPC or PLU in the database, depending on which one is not null, to get the product id
    # if on search there is no upc found then we will add the product to the database via the upc api
    if parameterUPC != "None":

        # query the product table to see if a product with the upc exists, if yes get the product id ONLY of the first match
        product = Product.query.filter_by(upc=parameterUPC).first()

        # product doesnt currently exist in the database
        if not product:
            # call the upc route function and capture the response
            response_tuple = apiCall(parameterUPC)


            if response_tuple[1] != 200:
                # if the product name is not null, then we will add the product to the database
                if name != None and name != "":
                    # add the product to the database
                    product = Product(name=name,
                                    upc=parameterUPC, plu = None, logical_delete=False)
                    db.session.add(product)
                    db.session.commit()
            else:
                # add the product to the database
                product = Product(name=response_tuple[0],
                                upc=parameterUPC, plu = None, logical_delete=False)
                db.session.add(product)
                db.session.commit()
                
                # get the product id from the newly added upc from the database
                product = Product.query.filter_by(upc=parameterUPC).first()
    elif plu:
        product = Product.query.filter_by(plu=plu).first()
        if not product:
            return jsonify({'error': 'PLU not found'}), 404
    else:
        return jsonify({'error': 'No UPC or PLU provided'}), 400
    

    # now we have to see if the name provided matches the name of the product in the database 
    # if they are different then we will create a new entry in the User's alias table
    # if an alias for the product id already exists, then we will replace the alias with the new one
    if name != product.name and name != None and name != "":
        # check to see if there is already an alias for the product
        alias = Alias.query.filter_by(user_id=user_id, product_id=product.id).first()
        # if there is an alias, then we will update it
        if alias:
            alias.alias = name
            db.session.commit()
        # if there is no alias, then we will create one
        else:
            alias = Alias(user_id=user_id, product_id=product.id, alias=name)
            db.session.add(alias)
            db.session.commit()


    # see if in the json there is an entry for location, if not then default to pantry
    if location == None:
        location = 'pantry'

    # Deal with Time and expiration Dates
    if request.json['date_added'] != None:
        date_added = datetime.strptime(str(request.json['date_added']), '%Y-%m-%dT%H:%M:%S.%f')

        # truncate the miliseconds from the datetime object
        date_added = date_added.replace(microsecond=0)

    if request.json['expiration_date'] != None:
        expiration_date = datetime.strptime(str(request.json['expiration_date']), '%Y-%m-%dT%H:%M:%S.%f')
        date_added = date_added.replace(microsecond=0)
    else:
        # query the expiration table to see if this product has an expiration date
        expiration = ExpirationData.query.filter_by(product_id=product.id).first()


        # make sure expiration is not null
        if expiration:

            # check the location of the product
            if location == 'fridge':
                exp_time = expiration.expiration_time_fridge
            elif location == 'freezer':
                exp_time = expiration.expiration_time_freezer
            elif location == 'pantry':
                exp_time = expiration.expiration_time_pantry

            # check if expiration time is null
            if exp_time:
                expiration_date = date_added + timedelta(days=exp_time)
            else:
                expiration_date = None
        else:
            expiration_date = None


    # ok so by here we have the plu or upc and the product id, as well as the date created
    # now we need to add the product to the pantry
    pantry = Pantry(user_id=user_id,
                    product_id=product.id,
                    date_added=date_added,
                    date_removed=None,
                    # if the location is not provided, we will default it to pantry
                    location=location,
                    expiration_date=expiration_date,
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

            if item.expiration_date != None:
                expiration_date = item.expiration_date
            else:
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
          
            # check to see where the food is stored and conver to int for the front end
            if item.location == 'pantry':
                location = 1
            elif item.location == 'fridge':
                location = 2
            elif item.location == 'freezer':
                location = 3
            else:
                location = 1

            # Check the alias table to see if an alias exists for the product given the user id
            alias_obj = Alias.query.filter_by(user_id=user_id, product_id=item.product_id).first()

            # if an alias exists, then we will use that instead of the product name
            if alias_obj:
                name = alias_obj.alias
            else:
                name = product.name

    
            # create a dictionary of the pantry item details
            pantry_item = {
                'id': item.id,
                'name': name,
                # if none type then return null
                'date_added': item.date_added,
                'date_removed': item.date_removed,
                'location': location,
                'quantity': item.quantity,
                'upc': product.upc,
                'plu': product.plu,
                'expiration_date': expiration_date,
                'is_deleted': int(item.is_deleted),
                'upc': product.upc,
                'plu': product.plu
            }

           

            # add the dictionary to the list
            pantry_list.append(pantry_item)

        # print(pantry_list)

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

    # print the entire json
    print(request.json)

    date_added = datetime.strptime(str(request.json['date_added']), '%Y-%m-%dT%H:%M:%S.%f')

    # get the session token from the authorization html header
    session_token = request.headers.get('Authorization').split()[1]
    
    # get the user id from the session token
    user_id = User.query.filter_by(session_token=session_token).first().id

    # search the pantry table for where the user id and the date_added match
    pantry = Pantry.query.filter_by(user_id=user_id, date_added=date_added).first()

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
        if request.json['date_added'] != None:

            # convert the date ISO8601 format to a datetime object
            date_added = datetime.strptime(request.json['date_added'], '%Y-%m-%dT%H:%M:%S.%f')

            pantry.date_added = date_added
        if request.json['date_removed']:
            # convert the date ISO8601 format to a datetime object
            date_removed = datetime.strptime(request.json['date_removed'], '%Y-%m-%dT%H:%M:%S.%f')

            pantry.date_removed = date_removed

            # if we have date removed then we can calculate the expiration date
            if pantry.location == 'pantry' and expiration.expiration_time_pantry != None:
            # subtract the date removed from the date added to get the number of days the food was in the pantry
                exp_time = date_removed - pantry.date_added
                # add this information to the expiration table
                expiration.expiration_time_pantry = int(exp_time.days)
            elif pantry.location == 'fridge' and expiration.expiration_time_fridge != None:
                # subtract the date removed from the date added to get the number of days the food was in the fridge
                exp_time = date_removed - pantry.date_added
                # add this information to the expiration table
                expiration.expiration_time_fridge = int(exp_time.days)
            elif pantry.location == 'freezer' and expiration.expiration_time_freezer != None:
                # subtract the date removed from the date added to get the number of days the food was in the freezer
                exp_time = date_removed - pantry.date_added
                # add this information to the expiration table
                expiration.expiration_time_freezer = int(exp_time.days)

        if request.json['location']:
            if request.json['location'] == 1:
                location = "pantry"
            elif request.json['location'] == 2:
                location = "fridge"
            elif request.json['location'] == 3:
                location = "freezer"
            else:
                location = "pantry"

            pantry.location = location  
        else:
            pantry.location = "pantry"

        if request.json['upc']:
            product.upc = request.json['upc']
        if request.json['plu']:
            product.plu = request.json['plu']
        if request.json['expiration_date']:
            pantry.expiration_date = datetime.strptime(request.json['expiration_date'], '%Y-%m-%dT%H:%M:%S.%f')
        if request.json['quantity']:
            pantry.quantity = request.json['quantity']
        if request.json['is_deleted'] == 0 or request.json['is_deleted'] == 1:
            pantry.is_deleted = request.json['is_deleted']

        print(location)

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
    

# create a route to delete an item in the pantry
@app.route('/deletePantryItem', methods=['POST'])
@jwt_required() # authentication Required
def deletePantryItem():
# expected input:
# {
    # date_added: "2020-01-01T00:00:00.000Z"
# }

    # get the session token from the authorization html header
    session_token = request.headers.get('Authorization').split()[1]

    # get the user id from the session token
    user_id = User.query.filter_by(session_token=session_token).first().id

    # convert the date ISO8601 format to a datetime object
    date_added = datetime.strptime(request.json['date_added'], '%Y-%m-%dT%H:%M:%S.%f')

    # search the pantry table for where the user id and the date_added match
    pantry = Pantry.query.filter_by(user_id=user_id, date_added=date_added).first()

    # check to see if the pantry item exists
    if not pantry:
        return jsonify({'error': 'Pantry item not found'}), 404
    else:
        db.session.delete(pantry)

        # commit the changes to the database
        db.session.commit()

        return jsonify({'message': 'Pantry item deleted successfully'}), 201
    

