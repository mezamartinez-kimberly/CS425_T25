/* 
==============================
*    Title: forgot_password.dart
*    Author: John Watson
*    Date: Feb 2022
==============================
*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        ),
        onPressed: () {
          if (!formKey.currentState!.validate()) {
            formKey.currentState!.save();

            return;
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
      body: Form(
        key: formKey,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 25,
              ),
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
