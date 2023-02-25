import 'package:edna/screens/all.dart';
import 'package:flutter/material.dart';
import 'package:edna/backend_utils.dart';

class OtpEntryPage extends StatefulWidget {
  const OtpEntryPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OtpEntryPageState createState() => _OtpEntryPageState();
}

class _OtpEntryPageState extends State<OtpEntryPage> {
  String _otpCode = '';
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers =
      List.generate(5, (_) => TextEditingController());

  Widget _buildOtpCodeFormField() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // hide keyboard when user taps outside of the keyboard
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SizedBox(
        height: 80,
        width: 350,
        child: Form(
          key: _formKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              5,
              (index) => SizedBox(
                width: 50,
                child: TextFormField(
                  controller: _controllers[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a number';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                  onChanged: (String value) {
                    // if the user has entered 5 digits, then move to the next field
                    if (value.length == 1) {
                      FocusScope.of(context).nextFocus();
                    }

                    // update the otp code every time the user enters or deletes a digit
                    _otpCode = '';
                    for (int i = 0; i < 5; i++) {
                      _otpCode += _controllers[i].text;
                    }
                  },
                  onSaved: (String? value) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: const <Widget>[
        Text(
          'Verify your Identity',
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
          'Enter your One Time Password',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ],
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

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 50,
      width: 350,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () async {
          _formKey.currentState!.save(); // Always save the form data

          if (_formKey.currentState!.validate()) {
            print("code: $_otpCode");

            String result = await BackendUtils.verifyOTP(_otpCode);

            // Resolved an aync + naviagation issue
            // https://dart-lang.github.io/linter/lints/use_build_context_synchronously.html
            if (!mounted) return;

            if (result == "OTP is correct") {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NewPasswordPage()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Container(
                    alignment: Alignment.topCenter,
                    height: 15.0,
                    child: const Center(
                      child: Text(
                        'Incorrect OTP',
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
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // hide keyboard when user taps outside of the keyboard
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
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
              _buildOtpCodeFormField(),
              const SizedBox(
                height: 20,
              ),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}
