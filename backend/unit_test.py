import unittest
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from models import db, User, UserPreference, Person, Product, ExpirationData, Pantry
import requests

# initialize the app
app = Flask(__name__)
bcrypt = Bcrypt(app)
server_url = 'http://127.0.0.1:5000'

# configure the app
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///db.sqlite'


class TestApp(unittest.TestCase):

    def test_register_user(self):

        # create a sample user
        user = {
            "first_name": "John",
            "last_name": "Doe",
            "email": "johnDoe@gmail.com",
            "password": "password123"
        }

        # send a post request to register the user
        response = requests.post(server_url + '/register', json=user)

        # check that the response code is 200 (created)
        self.assertEqual(response.status_code, 201)

        # check that the response is correct
        self.assertEqual(response.json(), {
            "message": "User created successfully"
        })
        
if __name__ == '__main__':
    unittest.main()
