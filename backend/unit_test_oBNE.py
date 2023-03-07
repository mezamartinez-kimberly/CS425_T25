#Author: Kim

# import unittest
# from flask import Flask, request, jsonify
# from flask_sqlalchemy import SQLAlchemy
# from flask_bcrypt import Bcrypt
# from models import db, User, UserPreference, Person, Product, ExpirationData, Pantry
# import requests

# # initialize the app
# app = Flask(__name__)
# bcrypt = Bcrypt(app)
# server_url = 'http://127.0.0.1:5000'

# # configure the app
# app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///db.sqlite'

# #create a class for testing the obtainUserNameEmail backend function
# class TestApp(unittest.TestCase):

#     #send a request to the backend to obtain the user's name and email
#     def test_obtainUserNameEmail(self):

#         #send a request to the backend to obtain the user's name and email
#         response = requests.get(server_url + '/obtainUserNameEmail', params = {'user_id': 1})

#         #check if the response is successful
#         self.assertEqual(response.status_code, 200)

#         #check if the response is correct
#         self.assertEqual(response.json(), {
#            'name': 'Kim', 'email': '})

# if __name__ == '__main__':
#     unittest.main()
