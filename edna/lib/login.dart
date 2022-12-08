import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:edna/homepage.dart';

// create a class for login page

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String email, password;
  Widget _buildLogo() {
    // This creates a row widget for the Login Title
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 70),
          child: Text(
            'Login',
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
        const SizedBox(height: 8),

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
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.email,
                  color: Colors.grey,
                ),
                labelText: 'Enter your Email',
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
        const SizedBox(height: 30),

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
        const SizedBox(height: 8),

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
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.lock,
                  color: Colors.grey,
                ),
                labelText: 'Enter your Password',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgetPasswordButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.58,
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            "Forgot Password?",
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 181, 79, 79),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 1.4 * (MediaQuery.of(context).size.height / 20),
          width: 5 * (MediaQuery.of(context).size.width / 10),
          margin: const EdgeInsets.only(bottom: 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 105, 185, 187),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const HomePage();
                  },
                ),
                (_) => false,
              );
            },
            child: Text(
              "Login",
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

  Widget _buildOrRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: const Text(
            '- OR -',
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSocialBtnRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 60,
            width: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 105, 185, 187),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6.0)
              ],
            ),
            child: const Icon(
              FontAwesomeIcons.google,
              color: Colors.black,
            ),
          ),
        )
      ],
    );
  }

  // This Builds the container that has the login form
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
            height: MediaQuery.of(context).size.height * 0.62,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,

              // Build each of the attributes in the login Page
              children: <Widget>[
                _buildEmailRow(),
                _buildPasswordRow(),
                _buildForgetPasswordButton(),
                _buildLoginButton(),
                _buildOrRow(),
                _buildSocialBtnRow(),
                _buildSignUpBtn(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 0),
          child: TextButton(
            onPressed: () {},
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: 'Dont have an account yet? ',
                  style: GoogleFonts.quicksand(
                    fontSize: MediaQuery.of(context).size.height / 50,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: 'Sign Up',
                  style: GoogleFonts.quicksand(
                    fontSize: MediaQuery.of(context).size.height / 50,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 181, 79, 79),
                  ),
                )
              ]),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
    );
  }
}
