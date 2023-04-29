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
import 'package:edna/backend_utils.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({Key? key});

  @override
  AccountSettingsPageState createState() => AccountSettingsPageState();
}

class AccountSettingsPageState extends State<AccountSettingsPage> {
  String firstName = "";
  String lastName = "";
  String email = "";
  String newEmail = '';
  bool isFirstName = false;
  bool isLastName = false;
  bool isNewEmail = false;
  bool isPEmail = false;

  //create an initialization function to get user data
  @override
  void initState() {
    super.initState();
    _getUserData().then((_) {});
  }

  refresh() async {
    await _getUserData();
    setState(() {});
  }

  final formKey = GlobalKey<FormState>();

  // build first name field
  Widget _buildFirstNameField() {
    return SizedBox(
      height: 80,
      width: 300,
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'First Name',
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
          if (value != null && value.isNotEmpty && value.length > 30) {
            return 'Frist Name must be less than 30 characters';
          }
          return null;
        },
        onSaved: (String? value) {
          if (value != null && value.isNotEmpty) {
            firstName = value;
            isFirstName = true;
          } else {
            firstName = firstName;
            isFirstName = false;
          }
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
          labelText: 'Last Name',
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
          if (value != null && value.isNotEmpty && value.length > 30) {
            return 'Last Name must be less than 30 characters';
          }
          return null;
        },
        onSaved: (String? value) {
          if (value != null && value.isNotEmpty) {
            lastName = value;
            isLastName = true;
          } else {
            lastName = lastName;
            isLastName = false;
          }
        },
      ),
    );
  }

// build email field for updating email
// build email field for updating email
  Widget _buildNewEmailField() {
    return SizedBox(
      height: 80,
      width: 250,
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'New E-mail',
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
          if (value != null && value.isNotEmpty) {
            if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                .hasMatch(value)) {
              return 'Please enter a valid email address';
            }
          }
          return null;
        },
        onSaved: (String? value) {
          if (value != null && value.isNotEmpty) {
            newEmail = value;
            isNewEmail = true;
            email = newEmail; // update email variable
            setState(() {}); // trigger a rebuild
          } else {
            isNewEmail = false;
          }
        },
      ),
    );
  }

  //build email field for password reset
  Widget _buildPassEmailField() {
    return SizedBox(
      height: 80,
      width: 250,
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
          if (value!.isNotEmpty) {
            if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                .hasMatch(value)) {
              return 'Please enter a valid email address';
            }
          }
          return null;
        },
        onSaved: (String? value) {
          if (value!.isNotEmpty &&
              RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(value)) {
            isPEmail = true;
          } else {
            isPEmail = false;
          }
        },
      ),
    );
  }

  // create a circular back button thats in the upper left corner
  Widget _buildBackBtn() {
    return Container(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: SizedBox(
          height: 35,
          width: 35,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              backgroundColor: const Color(0xFF7D9AE4),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios,
              size: 20,
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
        onPressed: () async {
          formKey.currentState!.save(); // Always save the form data

          if (formKey.currentState!.validate()) {
            if (isFirstName) {
              _updateFirstName(firstName);
            }

            if (isLastName) {
              _updateLastName(lastName);
            }

            if (isNewEmail) {
              _updateEmail(newEmail);
            }

            if (isPEmail) {
              String result = await BackendUtils.sendOTPEmail(email);

              // Resolved an async + navigation issue
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
                      horizontal: 30.0,
                      vertical: 50,
                    ),
                  ),
                );
              }
            }
          }

          formKey.currentState!.reset();
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

  //function to get user data from backend
  Future<void> _getUserData() async {
    //get user data from backend
    List<String> userData = await BackendUtils.getUserData();
    setState(() {
      firstName = userData[0];
      lastName = userData[1];
      email = userData[2];
    });
  }

  //function to call /updateUserNameEmail from backend
  Future<void> _updateUserNameEmail(
      String firstName, String lastName, String email) async {
    //call /updateUserNameEmail from backend
    await BackendUtils.updateUserNameEmail(firstName, lastName, email);
    setState(() {
      firstName = firstName;
      lastName = lastName;
      email = email;
    });
  }

  //function to call updateFirstName from backend
  Future<void> _updateFirstName(String firstName) async {
    //call updateFirstName from backend
    await BackendUtils.updateFirstName(firstName);
    setState(() {
      firstName = firstName;
    });
  }

  //function to call updateLastName from backend
  Future<void> _updateLastName(String lastName) async {
    //call updateLastName from backend
    await BackendUtils.updateLastName(lastName);
    setState(() {
      lastName = lastName;
    });
  }

  //function to call updateEmail from backend
  Future<void> _updateEmail(String email) async {
    //call updateEmail from backend
    await BackendUtils.updateEmail(email);
    setState(() {
      email = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: <Widget>[
            _buildBackBtn(),
            const Padding(
              padding: EdgeInsets.only(
                  top: 20,
                  left: 70), // Adjust the top value as per your requirement
              child: Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
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
              Text(
                'Current Name: $firstName $lastName',
                style: const TextStyle(
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
              Text(
                'Current Email: $email',
                style: const TextStyle(
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
              _buildNewEmailField(),
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
              _buildPassEmailField(),
              const SizedBox(height: 20.0),
              _buildSubmitButton(),
            ],
          ),
        ),
      )),
    );
  }
}
