
from server import db
from flask_sqlalchemy import SQLAlchemy


# Define the Centralized Database Class
class Products(db.Model):
    __tablename__ = 'products'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    name = db.Column(db.String(300), nullable=False)
    upc = db.Column(db.String(12), nullable=False)
    plu = db.Column(db.String(5), nullable=False)
    
    # define the relationships
    user = db.relationship('Users', backref=db.backref('products', lazy=True))

    # define the constructor
    def __init__(self, name, upc, plu):
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

    # define the relationships
    product = db.relationship('Products', backref=db.backref('expiration_data', lazy=True))
    user = db.relationship('Users', backref=db.backref('expiration_data', lazy=True))

    # define the constructor
    def __init__(self, product_id, user_id, expiration_date_pantry, expiration_date_fridge, expiration_date_freezer):
        self.product_id = product_id
        self.user_id = user_id
        self.expiration_date_pantry = expiration_date_pantry
        self.expiration_date_fridge = expiration_date_fridge
        self.expiration_date_freezer = expiration_date_freezer

# Define the User Database Class
class Users(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), nullable=False)
    password = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(120), nullable=False)
    isFirstLogin = db.Column(db.Boolean, nullable=False)

    # define the constructor
    def __init__(self, username, password, email, isFirstLogin):
        self.username = username
        self.password = password
        self.email = email
        self.isFirstLogin = isFirstLogin
