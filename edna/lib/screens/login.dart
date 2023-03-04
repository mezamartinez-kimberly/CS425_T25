/* 
==============================
*    Title: login.dart
*    Author: John Watson
*    Date: Dec 2022
==============================
*/

import 'package:edna/backend_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:edna/screens/all.dart'; // all screens

// create a class for login page

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '';
  String password = '';
  final _formKey = GlobalKey<FormState>();

// Createa a widget for the logo and Title Page
  Widget _buildLogo() {
    return Column(
      children: const <Widget>[
        SizedBox(
          height: 50,
        ),
        Text(
          'Welcome Back',
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
          'Login to your Account',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  // Create a widget for the email field
  Widget _buildEmailField() {
    return SizedBox(
      height: 80,
      width: 350,
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          // show the label text even when unfocused
          labelText: 'E-mail',
          labelStyle: GoogleFonts.openSans(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          prefixIcon: const Icon(
            FontAwesomeIcons.envelope,
            color: Colors.black,
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

// create a widget for the password field
  Widget _buildPasswordField() {
    return SizedBox(
      height: 70,
      width: 350,
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: GoogleFonts.openSans(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          prefixIcon: const Icon(
            FontAwesomeIcons.lock,
            color: Colors.black,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (String? value) {
          if (value!.isEmpty) {
            return 'Password is required';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
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

// Create a Widget for the login button
  Widget _buildLoginBtn() {
    return SizedBox(
      height: 60,
      width: 350,
      // padding: const EdgeInsets.symmetric(vertical: 25),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'RobotoMono',
          ),
        ),

        // When you press the button validate the form and send the information to the backend
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();

            // print the email and password to the console
            print('Email: $email');
            print('Password: $password');

            // Send the information to the backend
            String result = await BackendUtils.loginUser(email, password);
            print(result);

            // Resolved an async + navigation issue
            // https://dart-lang.github.io/linter/lints/use_build_context_synchronously.html
            if (!mounted) return;

            if (result == 'Login successful') {
              // Navigate to the home page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else {
              // Show an in line error message on top of the email field
              // Show an in line error message ontop of the email field
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Container(
                    alignment: Alignment.topCenter,
                    height: 15.0,
                    child: const Center(
                      child: Text(
                        'Please check your credentials and try again',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  backgroundColor: const Color.fromARGB(255, 255, 55, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 50),
                ),
              );
            }
          }
        },
      ),
    );
  }

// create the forgot password button this should be the same type of hyperlink as the register button
  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.center,
      child: TextButton(
        // on press navigate to the forgot password page
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
        ),

        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            fontFamily: 'RobotoMono',
          ),
        ),
      ),
    );
  }

// Create a Widget for the register button
  Widget _buildRegisterBtn() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegisterPage()),
      ),
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Don\'t have an Account? ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Register',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Create a divider to seperate the log in from the login with google
  Widget _buildOrRow() {
    return Row(
      children: const <Widget>[
        Expanded(
          child: Divider(
            color: Colors.black,
            height: 1.5,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.black,
            height: 1.5,
          ),
        ),
      ],
    );
  }

// build the Social Media Login Button based on the image asset
  Widget _buildSocialBtn() {
    return Row(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: () => {},
            child: Container(
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Image(
                    image: AssetImage('assets/logos/g-logo.png'),
                    height: 30,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Log in with Google',
                    style: TextStyle(
                      fontFamily: 'Roboto-Medium',
                      color: Color.fromARGB(255, 108, 108, 108),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

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
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 50,
                    ),
                    _buildLogo(),
                    const SizedBox(
                      height: 40,
                    ),
                    _buildEmailField(),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildPasswordField(),
                    _buildForgotPasswordBtn(),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildLoginBtn(),
                    const SizedBox(
                      height: 20,
                    ),
                    _buildOrRow(),
                    const SizedBox(
                      height: 20,
                    ),
                    _buildSocialBtn(),
                    const SizedBox(
                      height: 20,
                    ),
                    _buildRegisterBtn(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
