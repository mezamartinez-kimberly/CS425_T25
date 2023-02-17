from db import db
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# if you change the Database's schema, you need to delete the db.sqlite file in the isntance folder
# then run the following commands in the terminal after stopping the currecnt flask server.

# flask shell
# db.create_all() 

# then restart your server with:
# flask --app server run

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class User(db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    person_id = db.Column(db.Integer, db.ForeignKey('person.id'), unique=True)
    user_preference_id = db.Column(db.Integer, db.ForeignKey('user_preference.id'), unique=True)
    username = db.Column(db.String(80), nullable=True)
    password_hash = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(120), nullable=False)
    session_token = db.Column(db.String(120), nullable=True)

    # relationships
    pantry = db.relationship("Pantry", backref="user")

    def __init__(self, person_id, user_preference_id, username, password, email, session_token):
        self.person_id = person_id
        self.user_preference_id = user_preference_id
        self.username = username
        self.password_hash = password
        self.email = email
        self.session_token = session_token

    def check_password(self, password):
        return Bcrypt.check_password_hash(self.password_hash, password)


class UserPreference(db.Model):
    __tablename__ = 'user_preference'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    is_first_login = db.Column(db.Boolean, nullable=False)
    leaderboard_points = db.Column(db.Integer, nullable=False)
    is_dark_mode = db.Column(db.Boolean, nullable=False)
    is_notifications_on = db.Column(db.Boolean, nullable=False)
    notification_range = db.Column(db.Integer, nullable=False)

    users = db.relationship("User", backref="user_preference", uselist=False)

    def __init__(self, is_first_login, leaderboard_points, is_dark_mode, is_notifications_on, notification_range):
        self.is_first_login = is_first_login
        self.leaderboard_points = leaderboard_points
        self.is_dark_mode = is_dark_mode
        self.is_notifications_on = is_notifications_on
        self.notification_range = notification_range


class Person(db.Model):
    __tablename__ = 'person'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    first_name = db.Column(db.String(30), nullable=False)
    last_name = db.Column(db.String(30), nullable=False)
    alias = db.Column(db.String(30), nullable=True)

    users = db.relationship("User", backref="person", uselist=False)

    def __init__(self, first_name, last_name, alias):
        self.first_name = first_name
        self.last_name = last_name
        self.alias = alias


class Product(db.Model):
    __tablename__ = 'product'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(300), nullable=False)
    upc = db.Column(db.String(12), nullable=True)
    plu = db.Column(db.String(5), nullable=True)
    logical_delete = db.Column(db.Boolean, nullable=False)

    pantry = db.relationship("Pantry", backref="product")

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
    
    # define the constructor
    def __init__(self, user_id, product_id, expiration_time_pantry, expiration_time_fridge, expiration_time_freezer):
        self.user_id = user_id
        self.product_id = product_id
        self.expiration_time_pantry = expiration_time_pantry
        self.expiration_time_fridge = expiration_time_fridge
        self.expiration_time_freezer = expiration_time_freezer

# Define the Pantry Database Class
class Pantry(db.Model):
    __tablename__ = 'pantry'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    product_id = db.Column(db.Integer, db.ForeignKey('product.id'), nullable=False)
    date_added = db.Column(db.DateTime, nullable=False)
    date_removed = db.Column(db.DateTime, nullable=True)
    location = db.Column(db.String(30), nullable=False)
    quantity = db.Column(db.Integer, nullable=False)
    is_deleted = db.Column(db.Boolean, nullable=False)

    # define the constructor
    def __init__(self, user_id, product_id, date_added, date_removed, location, quantity, is_deleted):
        self.user_id = user_id
        self.product_id = product_id
        self.date_added = date_added
        self.date_removed = date_removed
        self.location = location
        self.quantity = quantity
        self.is_deleted = is_deleted
