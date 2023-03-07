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
import 'package:edna/utils/backend_utils.dart';
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
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  final formKey = GlobalKey<FormState>();

// build Logo
  Widget _buildLogo() {
    return Column(
      children: const <Widget>[
        SizedBox(
          height: 50,
        ),
        Text(
          'Register',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'Create you new account',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

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
          // prefixIcon: const Icon(
          //   FontAwesomeIcons.envelope,
          //   color: Colors.black,
          // ),
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

// create a widget for the password field
  Widget _buildPasswordField() {
    return SizedBox(
      height: 90,
      width: 300,
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Password*',
          helperText: "Must contain 8 characters",
          labelStyle: GoogleFonts.openSans(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          // prefixIcon: const Icon(
          //   FontAwesomeIcons.lock,
          //   color: Colors.black,
          // ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (String? password) {
          if (password!.isEmpty) {
            return 'Password is required';
          }
          if (password.length < 8) {
            return 'Password must be at least 8 characters';
          }
          return null;
        },
        onSaved: (String? value) {
          password = value!;
        },
        obscureText: true,
      ),
    );
  }

// create a widget fo the confirm password field
  Widget _buildConfirmPasswordField() {
    return SizedBox(
      height: 90,
      width: 300,
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Confirm Password',
          labelStyle: GoogleFonts.openSans(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          // prefixIcon: const Icon(
          //   FontAwesomeIcons.lock,
          //   color: Colors.black,
          // ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (String? confirmPassword) {
          if (confirmPassword!.isEmpty) {
            return 'Password is required';
          }

          print(password);
          print(confirmPassword);

          if (password != confirmPassword) {
            return 'Passwords do not match';
          }
          return null;
        },
        onSaved: (String? value) {
          confirmPassword = value!;
        },
        obscureText: true,
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 60,
      width: 300,
      // padding: const EdgeInsets.symmetric(vertical: 25),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () async {
          formKey.currentState!.save();
          if (!formKey.currentState!.validate()) {
            formKey.currentState!.save();
            return;
          }

          // send the validated data to the registerUser function
          String result = await BackendUtils.registerUser(
              firstName, lastName, email, password);

          // Resolved an async + navigation issue
          // https://dart-lang.github.io/linter/lints/use_build_context_synchronously.html
          if (!mounted) return;

          if (result == "Registration successful") {
            // create an alert dialog to show the user that they have successfully registered
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text("Registration Successful!"),
                    content:
                        const Text("Please login to continue into the app."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          if (!mounted) return;
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()));
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  );
                });
          } else {
            // Error message for Email already exists
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text("Registration Failed"),
                    content: Text(result),
                    actions: [
                      TextButton(
                        onPressed: () {
                          if (!mounted) return;
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()));
                        },
                        child: const Text("Try Again"),
                      ),
                      TextButton(
                        // direct the user to the forgot password page
                        onPressed: () {
                          if (!mounted) return;
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordPage()));
                        },
                        child: const Text("Forgot Password"),
                      ),
                    ],
                  );
                });
          }
        },
        child: const Text(
          'Register',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }

// create a circular back button thats in the upper left corner
  Widget _buildBackBtn() {
    return Container(
      // pushh the button down
      padding: const EdgeInsets.only(top: 10),
      alignment: Alignment.centerLeft,

      // wrap in circular button
      child: SizedBox(
        height: 35,
        width: 35,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(0),
          ),
          onPressed: () => Navigator.pop(context),
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

  // create build method
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formKey,
            child: ListView(
              children: <Widget>[
                _buildBackBtn(),
                _buildLogo(),
                const SizedBox(
                  height: 40,
                ),
                _buildFirstNameField(),
                _buildLastNameField(),
                _buildEmailField(),
                _buildPasswordField(),
                _buildConfirmPasswordField(),
                _buildRegisterButton(),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
