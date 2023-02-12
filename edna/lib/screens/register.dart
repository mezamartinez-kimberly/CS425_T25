/* 
==============================
*    Title: login.dart
*    Author: John Watson
*    Date: Feb 2022
==============================
*/

import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:edna/screens/all.dart'; // all screens

// create a class for login page

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late String firstName, lastName, email, password;

  final _formKey = GlobalKey<FormState>();

  Widget _buildLogo() {
    // This creates a row widget for the Login Title
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 40),
          child: Text(
            'Register',
            style: GoogleFonts.notoSerif(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildFirstNameRow() {
    final theme = ThemeData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        // add padding to the top of the text field
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            // This Text widget is the label for the Name Field
            'First Name',
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        // This Sized Box widget is the space between the label and the field
        const SizedBox(height: 0),

        // This Container widget is the field itself
        Container(
          alignment: Alignment.centerLeft,
          height: MediaQuery.of(context).size.height / 15,
          width: MediaQuery.of(context).size.width / 1.25,
          child: Theme(
            // This theme wrapper helps me change the color of the Label and Underline when inputting data
            data: Theme.of(context).copyWith(
                colorScheme: theme.colorScheme.copyWith(
              primary: const Color.fromARGB(255, 181, 79, 79), // NEW WAY
            )),

            child: TextFormField(
              // validator to ensure value is under 30 characters
              validator: (value) {
                if (value!.length > 30) {
                  return 'First Name must be under 30 characters';
                }
                return null;
              },

              onChanged: (value) {
                setState(() {
                  firstName = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Enter your First Name',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastNameRow() {
    final theme = ThemeData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          // This Text widget is the label for the Name Field
          'Last Name',
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        // This Sized Box widget is the space between the label and the field
        const SizedBox(height: 0),

        // This Container widget is the field itself
        Container(
          alignment: Alignment.centerLeft,
          height: MediaQuery.of(context).size.height / 15,
          width: MediaQuery.of(context).size.width / 1.25,
          child: Theme(
            // This theme wrapper helps me change the color of the Label and Underline when inputting data
            data: Theme.of(context).copyWith(
                colorScheme: theme.colorScheme.copyWith(
              primary: const Color.fromARGB(255, 181, 79, 79), // NEW WAY
            )),

            child: TextFormField(
              validator: (value) {
                if (value!.length > 30) {
                  return 'Last Name must be under 30 characters';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  lastName = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Enter your Last Name',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailRow() {
    // Creates the Email Row
    final theme = ThemeData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          // This Text widget is the label for the Email Field
          'Email',
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        // This Sized Box widget is the space between the label and the field
        const SizedBox(height: 0),

        // This Container widget is the field itself
        Container(
          alignment: Alignment.centerLeft,
          height: MediaQuery.of(context).size.height / 15,
          width: MediaQuery.of(context).size.width / 1.25,
          child: Theme(
            // This theme wrapper helps me change the color of the Label and Underline when inputting data
            data: Theme.of(context).copyWith(
                colorScheme: theme.colorScheme.copyWith(
              primary: const Color.fromARGB(255, 181, 79, 79), // NEW WAY
            )),

            child: TextFormField(
              keyboardType: TextInputType.emailAddress,

              // make a validator to ensure the email is valid use a regulr expression to ensure the email is valid
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter an email';
                }
                if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                    .hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },

              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Enter your Email',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRow() {
    // create a cloumn widget for the text field label
// create a row widget for the text form field
    final theme = ThemeData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // This Sized Box widget is the space between the label and the field
        const SizedBox(height: 10),

        Text(
          // This Text widget is the label for the Email Field
          'Password',
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        // This Sized Box widget is the space between the label and the field
        const SizedBox(height: 0),

        // This Container widget is the field itself
        Container(
          alignment: Alignment.centerLeft,
          height: MediaQuery.of(context).size.height / 15,
          width: MediaQuery.of(context).size.width / 1.25,
          child: Theme(
            // This theme wrapper helps me change the color of the Label and Underline when inputting data

            data: Theme.of(context).copyWith(
                colorScheme: theme.colorScheme.copyWith(
              primary: const Color.fromARGB(255, 181, 79, 79), // NEW WAY
            )),

            child: TextFormField(
              obscureText: true,
              validator: ((value) {
                if (value!.isEmpty) {
                  return 'Please enter a password';
                } else if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              }),
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Enter your Password',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordRow() {
    // create a cloumn widget for the text field label
// create a row widget for the text form field
    final theme = ThemeData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // This Sized Box widget is the space between the label and the field
        const SizedBox(height: 10),

        Text(
          // This Text widget is the label for the Email Field
          'Confirm your Password',
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        // This Sized Box widget is the space between the label and the field
        const SizedBox(height: 0),

        // This Container widget is the field itself
        Container(
          alignment: Alignment.centerLeft,
          height: MediaQuery.of(context).size.height / 15,
          width: MediaQuery.of(context).size.width / 1.25,
          child: Theme(
            // This theme wrapper helps me change the color of the Label and Underline when inputting data

            data: Theme.of(context).copyWith(
                colorScheme: theme.colorScheme.copyWith(
              primary: const Color.fromARGB(255, 181, 79, 79), // NEW WAY
            )),

            // This in here is where we get the value from the confim myour password field
            child: TextFormField(
              obscureText: true,
              validator: (value) {
                if (password != value) {
                  return 'passwords do not match';
                }
                return null;
              },
              decoration: const InputDecoration(
                  hintText: 'Re-Type your Password',
                  labelStyle: TextStyle(fontSize: 18, color: Colors.grey)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 1.4 * (MediaQuery.of(context).size.height / 20),
          width: 5 * (MediaQuery.of(context).size.width / 10),
          margin: const EdgeInsets.only(top: 20, bottom: 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 105, 185, 187),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                //Open a snack bar and display all the user infomation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Email: $email \n Password: $password',
                    ),
                  ),
                );
                // If The Information is Valid Send them to the Login Page

                // Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                // MaterialPageRoute(
                //   builder: (BuildContext context) {
                //     return const HomePage();
                //   },
                // ),
                // (_) => false,
                // );

              } else {
                // If any information is invalid, display error messages
                return;
              }
            },
            child: Text(
              "Register",
              style: GoogleFonts.notoSerif(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          // This Clips the border Radius of the Container
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),

          child: Container(
            // This sets the attributes of the Container
            height: MediaQuery.of(context).size.height * 0.80,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),

            // Note to future me: SingleChildScroll only allows for that scrolling IFF its in a scaffold
            child: Scaffold(
              body: SingleChildScrollView(
                reverse: true,
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildFirstNameRow(),
                      _buildLastNameRow(),
                      _buildEmailRow(),
                      _buildPasswordRow(),
                      _buildConfirmPasswordRow(),
                      _buildRegisterButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // add gesture decetor to detect the tap and unfocus the text field
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color.fromARGB(255, 218, 218, 218),
          body: Stack(
            // This Child is the Background for the Login Page
            children: <Widget>[
              // create a circle in the upper right hand corner

              Positioned(
                // Upper right circle
                top: -MediaQuery.of(context).size.height * 0.4,
                right: -MediaQuery.of(context).size.width * 0.5,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 181, 79, 79),
                  ),
                ),
              ),

              Positioned(
                // Middle Left Circle
                bottom: -MediaQuery.of(context).size.height * -0.4,
                left: -MediaQuery.of(context).size.width * 0.2,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 181, 79, 79),
                  ),
                ),
              ),

              Positioned(
                // Bottom Left Circle
                bottom: -MediaQuery.of(context).size.height * 0.3,
                left: -MediaQuery.of(context).size.width * 0.4,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 181, 79, 79),
                  ),
                ),
              ),

              Positioned(
                // Middle Right Circle
                bottom: -MediaQuery.of(context).size.height * -0.2,
                right: -MediaQuery.of(context).size.width * 0.2,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 181, 79, 79),
                  ),
                ),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildLogo(),
                  _buildContainer(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
