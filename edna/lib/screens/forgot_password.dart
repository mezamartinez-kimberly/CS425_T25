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

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPasswordPage> {
  late String email;
  final formKey = GlobalKey<FormState>();

  Widget _buildTitle() {
    return Column(
      children: const <Widget>[
        Text(
          'Forgot Password',
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
          'Enter your email to reset your password',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return SizedBox(
      height: 80,
      width: 350,
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'E-mail',
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

  Widget _buildResetPasswordButton() {
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
          formKey.currentState!.save(); // Always save the form data

          if (formKey.currentState!.validate()) {
            // print email
            print(email);

            String result = await BackendUtils.sendOTPEmail(email);

            // Resolved an aync + naviagation issue
            // https://dart-lang.github.io/linter/lints/use_build_context_synchronously.html
            if (!mounted) return;

            if (result == "Email sent successfully") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OtpEntryPage()),
              );
            } else {
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
        child: const Text(
          'Reset Password',
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
              _buildEmailField(),
              const SizedBox(
                height: 20,
              ),
              _buildResetPasswordButton(),
            ],
          ),
        ),
      ),
    );
  }
}
