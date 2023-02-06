# reference: https://pythonbasics.org/flask-sqlalchemy/

from flask import Flask,jsonify, request
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
class Users(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), nullable=False)
    password = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(120), nullable=False)
    isFirstLogin = db.Column(db.Boolean, nullable=False)

    # define the relationships
    expiration_data_child = db.relationship("ExpirationData", back_populates="user_parent_2")    
    products_child = db.relationship("Products", back_populates="user_parent_1")

    # define the constructor
    def __init__(self, username, password, email, isFirstLogin):
        self.username = username
        self.password = password
        self.email = email
        self.isFirstLogin = isFirstLogin

# Define the Centralized Database Class
class Products(db.Model):
    __tablename__ = 'products'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    name = db.Column(db.String(300), nullable=False)
    upc = db.Column(db.String(12), nullable=True)
    plu = db.Column(db.String(5), nullable=True)

    # define the relationships
    # uselist = False means that there is only one ExpirationData object per Product
    # https://docs.sqlalchemy.org/en/14/orm/basic_relationships.html 
    expiration_data = db.relationship('ExpirationData', uselist=False, backref='product', lazy=True)
    user_parent_1 = db.relationship("Users", back_populates="products_child")

    # define the constructor
    def __init__(self, user_id,name, upc, plu):
        self.user_id = user_id
        self.name = name
        self.upc = upc
        self.plu = plu

# Define the Expiration Database Class
class ExpirationData(db.Model):
    __tablename__ = 'expiration_data'
    id = db.Column(db.Integer, primary_key=True)
    product_id = db.Column(db.Integer, db.ForeignKey('products.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    expiration_date_pantry = db.Column(db.Integer)
    expiration_date_fridge = db.Column(db.Integer)
    expiration_date_freezer = db.Column(db.Integer)

    #define the relationship
    user_parent_2 = db.relationship("Users", back_populates="expiration_data_child")

    # define the constructor
    def __init__(self, product_id, user_id, expiration_date_pantry, expiration_date_fridge, expiration_date_freezer):
        self.product_id = product_id
        self.user_id = user_id
        self.expiration_date_pantry = expiration_date_pantry
        self.expiration_date_fridge = expiration_date_fridge
        self.expiration_date_freezer = expiration_date_freezer


# db.create_all()

# ~~~~~~~~~~~~~~~~~~~~~~~~~~ DATABASE SETUP end ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# ~~~~~~~~~~~~~~~~~~~~~~~~~~ ROUTE SETUP ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# API route to get add a product to the database
@app.route('/products/add', methods=['POST'])
def add_product():
    if request.method == 'POST':
        data = request.get_json()
        user_id = data['user_id']
        name = data['name']
        upc = data['upc']
        plu = data['plu']

    new_product = Products(name=name,user_id=user_id ,upc=upc, plu=plu)
    db.session.add(new_product)
    db.session.commit()
    # return jsonify(upc)
    return jsonify({'message': 'Product added successfully'})


# if __name__ == '__main__':
#    db.create_all()
#    app.run(debug = True)