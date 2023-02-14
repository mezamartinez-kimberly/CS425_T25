/*
==============================
*    Title: theme.dart
*    Author: Cade Hockersmith
*    Date: Feb 2022
==============================
*/

/* References: 
https://docs.flutter.dev/cookbook/design/themes
https://medium.com/flutter-community/themes-in-flutter-part-1-75f52f2334ea
https://www.flutterbeads.com/change-theme-text-color-in-flutter/

*/

//Imports
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConstants {
  static final ThemeData lightTheme = ThemeData(
    //Initial Theme Setup
    brightness: Brightness.light,

    //Universal Styles - Text
      //fontFamily: 'Raleway', //Esablishing the font family used throughout the project.
      
      displayLarge: TextStyle(color: Colors.deepPurpleAccent,), //Largest text, for most significant element on the page.
      displayMedium: TextStyle(color: Colors.deepPurpleAccent),
      displaySmall: TextStyle(color: Colors.deepPurpleAccent),

<<<<<<< Updated upstream
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
=======
      headlineLarge: TextStyle(color: Colors.deepPurpleAccent), //Short, high-emphasis text
      headlineMedium: TextStyle(color: Colors.deepPurpleAccent),
      headlineSmall: TextStyle(color: Colors.deepPurpleAccent),
>>>>>>> Stashed changes

      bodyLarge: TextStyle(color: Colors.deepPurpleAccent), //Long blocks of text
      bodyMedium: TextStyle(color: Colors.deepPurpleAccent),
      bodySmall: TextStyle(color: Colors.deepPurpleAccent),

      labelLarge: TextStyle(color: Colors.deepPurpleAccent), //Text inside of components
      labelMedium: TextStyle(color: Colors.deepPurpleAccent),
      labelSmall: TextStyle(color: Colors.deepPurpleAccent), 
    //Universal Styles - Color 
      primaryColor: Colors.blue, //Primary Application Elements
      primaryContainer: Colors.lightBlue, 
      secondaryColor: Colors.red,
      secondaryContainer: Colors.orange, 
      canvasColor: Colors.white;
      
      accentColor: Colors.red; //Foreground Color
      accentColorBrightness: Brightness.light,

      bottomAppBarColor: Colors.blue;
      cardColor: Colors.blue;
      dividerColor: Colors.blue;

       unselectedWidgetColor: Colors.blue; // Inactive but visible widgets.
       disabledColor: Colors.blue; //Disabled Widgets

    //Universal Styles - UI Elements 
    buttonColor: Colors.blue;
    errorColor: Colors.blue; //Input Validation Input Boxes
    /*Calendar Specifc
    style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  fixedSize: const Size(200, 50),
                                ),

                                style: GoogleFonts.notoSerif(
                    fontSize: 31,
                    color: Colors.black,
                  ),
    */
    /*Camera Specific
  style: const ButtonStyle(
                                              backgroundColor:
                                                  MaterialStatePropertyAll(
                                                      Colors.blue)),
                                          child: const Text(
                                            'Accept All',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20),
                                            textAlign: TextAlign.center,
                                          ),

                                          Elevated Button
    */

    //Homepage Specific - Widget has hard-coded styles, will need to convert it over.
    
    /*Login Specific
'Email',
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        Elevated Button
        */
    //Pantry Specific - Widget has hard-coded styles, will need to convert it over.

    //Profile Specific
  /*child: Card(
                            color: myBlue,
                            child: SizedBox(
                                height: 70,
                                child: Center(
                                    // sized box contains row of icon and text
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.lock_outline),
                                    Text(' Login Info',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black)),
                                  ], */

    //Register Specific - Fonts, elevated button, containers

    //Statistics Specific - Title text style

    
    
    
    
    
  
  );
}

