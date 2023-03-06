/* 
==============================
*    Title: account_settings.dart
*    Author: Kimberly Meza Martinez
*    Date: Feb 2023
==============================
*/

import 'package:flutter/material.dart';
import 'package:edna/screens/all.dart'; // all screens
import 'package:google_fonts/google_fonts.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({Key? key});

  @override
  AccountSettingsPageState createState() => AccountSettingsPageState();
}

class AccountSettingsPageState extends State<AccountSettingsPage>{

  String firstName = '';
  String lastName = '';
  String email = '';

  final formKey = GlobalKey<FormState>();

  // build first name field
  Widget _buildFirstNameField() {
    return SizedBox(
      height: 80,
      width: 300,
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'First Name*',
          labelStyle: GoogleFonts.openSans(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (String? value) {
          if (value!.isEmpty) {
            return 'First Name is Required';
          }
          if (value.length > 30) {
            return 'First Name must be less than 30 characters';
          }
          return null;
        },
        onSaved: (String? value) {
          firstName = value!;
        },
      ),
    );
  }

// build the last name field
  Widget _buildLastNameField() {
    return SizedBox(
      height: 80,
      width: 300,
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Last Name*',
          labelStyle: GoogleFonts.openSans(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        // create a validator that checks to see if the feild is empty and check that the value is under 30 characters
        validator: (String? value) {
          if (value!.isEmpty) {
            return 'Last Name is Required';
          }
          if (value.length > 30) {
            return 'Last Name must be less than 30 characters';
          }
          return null;
        },

        // save the value of the field
        onSaved: (String? value) {
          lastName = value!;
        },
      ),
    );
  }

// build email field
  Widget _buildEmailField() {
    return SizedBox(
      height: 80,
      width: 250,
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          // show the label text even when unfocused
          labelText: 'E-mail*',
          labelStyle: GoogleFonts.openSans(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (String? value) {
          if (value!.isEmpty) {
            return 'Email is required';
          }
          if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(value)) {
            return 'Please enter a valid email address';
          }
          return null;
        },
        onSaved: (String? value) {
          email = value!;
        },
      ),
    );
  }
  // create a circular back button thats in the upper left corner
  Widget _buildBackBtn() {
    return Container(
      // pushh the button down
      padding: const EdgeInsets.only(top: 10),
      alignment: Alignment.topLeft,
      // wrap in circular button
      child: SizedBox(
        height: 35,
        width: 35,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(0),
            backgroundColor: const Color(0xFF7D9AE4),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Container(
            alignment: Alignment.center,
            child: const Padding(
              padding: EdgeInsets.only(left: 7),
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 50,
      width: 350,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: const Color(0xFF7D9AE4),
        ),
        onPressed: () {
        },
        child: const Text(
          'Submit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: <Widget>[
            _buildBackBtn(),
            const Text('        Account Settings',
              style: TextStyle(fontSize: 30.0,
                color: Colors.black, 
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
      ),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: ListView(
              children: <Widget>[
                //name area
                const Text(
                  'Current Name:',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'New name:',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                 _buildFirstNameField(),
                _buildLastNameField(),
                const SizedBox(height: 20.0),
                //change email area
                const Text(
                  'Current Email:',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'New Email:',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                _buildEmailField(),
                const SizedBox(height: 20.0),
                //change password area
                const Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'Enter current email to send verification code:',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                _buildEmailField(),
                const SizedBox(height: 20.0),
                _buildSubmitButton(),
              ],
            ),
          ),
        )
      ),
    );
  }
}