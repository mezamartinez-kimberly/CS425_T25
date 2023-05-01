/* 
==============================
*    Title: forgot_password.dart
*    Author: John Watson
*    Date: Feb 2022
==============================
*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'all.dart';
import 'package:edna/backend_utils.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _NewPasswordState createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPasswordPage> {
  late String password, confirmPassword;

  final formKey = GlobalKey<FormState>();

  Widget _buildTitle() {
    return Column(
      children: const <Widget>[
        Text(
          'Change Password',
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
          'Enter your new password',
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
      height: 90,
      width: 350,
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
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromRGBO(247, 164, 162, 1),
              width: 2,
            ),
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
      height: 90,
      width: 350,
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
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromRGBO(247, 164, 162, 1),
              width: 2,
            ),
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
          if (password == value) {
            confirmPassword = value!;
          }
        },
        obscureText: true,
      ),
    );
  }

  // create a submit button
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
        onPressed: () async {
          formKey.currentState!.save();
          if (formKey.currentState!.validate()) {
            String result = await BackendUtils.changePassword(password);

            // Resolved an aync + naviagation issue
            // https://dart-lang.github.io/linter/lints/use_build_context_synchronously.html
            if (!mounted) return;

            if (result == 'New Password set') {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    //round the corners
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text('Password Changed'),
                    content: const Text(
                        'Your password has been changed successfully'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              // Show an in line error message on top of the email field
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const SizedBox(
                    height: 35.0,
                    child: Center(
                      child: Text(
                        "Your New Password can't be the same as your Old Password",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center, // Added to center the text
                      ),
                    ),
                  ),
                  backgroundColor: const Color.fromARGB(255, 255, 55, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 360),
                ),
              );
            }
          }
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
            backgroundColor: const Color(0xFF7D9AE4),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: formKey,
          child: ListView(
            children: <Widget>[
              _buildBackBtn(),
              const SizedBox(
                height: 80,
              ),
              _buildTitle(),
              const SizedBox(
                height: 30,
              ),
              _buildPasswordField(),
              const SizedBox(
                height: 20,
              ),
              _buildConfirmPasswordField(),
              const SizedBox(
                height: 20,
              ),
              _buildSubmitButton(),
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
