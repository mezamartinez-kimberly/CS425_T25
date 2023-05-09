/*
==============================
*    Title: theme.dart
*    Author: Julian Fliegler
*    Date: May 2023
==============================
*/

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyTheme extends StatelessWidget {
  var pinkColor = const Color.fromRGBO(247, 164, 162, 1);
  var blueColor = const Color.fromRGBO(147, 168, 221, 1);
  var orangeColor = const Color.fromARGB(255, 236, 165, 133);
  var greenColor = const Color.fromARGB(255, 126, 200, 121);

  // constructor
  MyTheme({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
