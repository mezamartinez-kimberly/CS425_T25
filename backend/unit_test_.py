# #Author: Kim

import unittest
import requests
from server import app, db
from models import User, Person
from flask import Flask
from flask_bcrypt import Bcrypt
from flask_jwt_extended import create_access_token
from flask_ngrok import run_with_ngrok
from server import obtainUserNameEmail

app = Flask(__name__)
bcrypt = Bcrypt(app)
run_with_ngrok(app)

# create a class for testing the obtainUserNameEmail backend function
class TestApp(unittest.TestCase):

    # configure the app
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///db.sqlite'

    # send a request to the backend to obtain the user's name and email
    def test_obtainUserNameEmail(self):
        # define test input/expected output
        first_name = 'John'
        last_name = 'Doe'
        email = 'jared@gmail.com'
        password = 'password123'
        expected_output = {'first_name': first_name, 'last_name': last_name, 'email': email}

        #create a post request for login
        create_access_token = requests.post('http://localhost:5000/login', json={'email': email, 'password': password})

        #extract the session token from the response
        session_token = create_access_token.json()['session_token']
        
        # create a post request to the backend for obtainUserNameEmail
        headers = {'Authorization': f'Bearer {session_token}'}
        response = requests.post('http://localhost:5000/obtainUserNameEmail', headers=headers)

        # check that the response is correct
        self.assertEqual(response.status_code, 200)

        # check that the output is correct
        self.assertEqual(response.json(), expected_output)

if __name__ == '__main__':
    unittest.main()