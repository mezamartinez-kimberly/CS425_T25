/* 
==============================
*    Title: shared_preferences.dart
*    Author: Kimberly Meza Martinez
*    Date: Feb 2023
==============================
*/
//Purpose: To assist with the change from dark/light mode.
/* Referenced code:
https://github.com/flutter-devs/Flutter-Devfest/blob/master/lib/utils/devfestpreferences.dart
*/

// import 'package:shared_preferences/shared_preferences.dart';

// class DarkThemePreference {
//   static const THEME_STATUS = "THEMESTATUS";

//   setDarkTheme(bool value) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setBool(THEME_STATUS, value);
//   }

//   Future<bool> getTheme() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(THEME_STATUS) ?? false;
//   }
// }