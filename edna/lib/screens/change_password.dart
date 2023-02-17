/* 
==============================
*    Title: change_password.dart
*    Author: John Watson
*    Date: Feb 2022
==============================
*/

import 'package:edna/screens/all.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  late String password;
  final formKey = GlobalKey<FormState>();

  Widget _buildTitle() {
    return Column(
      children: const <Widget>[
        Text(
          'Create New Password',
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
          'Enter a new password for your account',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  // create a widget for the password field
  Widget _buildPasswordField() {
    return SizedBox(
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
        validator: (String? value) {
          if (value!.isEmpty) {
            return 'Password is required';
          }
          if (value.length < 8) {
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
        validator: (String? value) {
          if (value!.isEmpty) {
            return 'Password is required';
          }
          if (password != value) {
            return 'Passwords do not match';
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

// build an exit button that takes the user to the login page the exit button should be a circle with a icon x in it
  Widget _buildExitButton() {
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

          // on pressed prompt a dialog box with a large corner radius to confirm exit
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text(
                    'Are you sure you want to exit?',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text(
                    'You will be taken to the Login Page',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Exit',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },

          child: Container(
            alignment: Alignment.center,
            child: const Padding(
              padding: EdgeInsets.only(left: 0),
              child: Icon(
                Icons.clear,
                size: 25,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 25,
              ),
              _buildExitButton(),
              const SizedBox(
                height: 80,
              ),
              _buildTitle(),
              const SizedBox(
                height: 20,
              ),
              _buildPasswordField(),
              const SizedBox(
                height: 20,
              ),
              _buildConfirmPasswordField(),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
