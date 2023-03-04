/*
==============================
*    Title: theme.dart
*    Author: Julian Fliegler
*    Date: Dec 2022
==============================
*/

/* References: 
https://medium.com/@nickysong/creating-a-custom-color-swatch-in-flutter-554bcdcb27f3
*/

import 'package:flutter/material.dart';

class MyTheme extends StatelessWidget {
  var pinkColor = const Color.fromRGBO(247, 164, 162, 1);
  var blueColor = const Color.fromRGBO(147, 168, 221, 1);

  // constructor
  MyTheme({Key? key}) : super(key: key);

  // function that allows user to create own material color type
  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
