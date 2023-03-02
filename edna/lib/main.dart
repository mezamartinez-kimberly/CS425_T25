import 'package:edna/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:edna/screens/all.dart'; // all screens
import 'package:another_flushbar/flushbar.dart'; // snackbars
import 'package:another_flushbar/flushbar_helper.dart'; // snackbars
import 'package:another_flushbar/flushbar_route.dart'; // snackbars

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }

  createErrorMessage(context, errorMsg) {
    var errorText = const Color.fromARGB(255, 88, 15, 15);
    var errorBackground = const Color.fromARGB(255, 238, 37, 37);

    Flushbar(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      message: errorMsg,
      messageSize: 25,
      messageColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : errorText,
      duration: const Duration(seconds: 3),
      backgroundColor: errorBackground,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      borderRadius: BorderRadius.circular(30.0),
    ).show(context);
  }

  createSuccessMessage(context, errorMsg) {
    var errorText = Color.fromARGB(255, 15, 88, 47);
    var errorBackground = Color.fromARGB(255, 78, 249, 36);

    Flushbar(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      message: errorMsg,
      messageSize: 25,
      messageColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : errorText,
      duration: const Duration(seconds: 3),
      backgroundColor: errorBackground,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      borderRadius: BorderRadius.circular(30.0),
    ).show(context);
  }
}
