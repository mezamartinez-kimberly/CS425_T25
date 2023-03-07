/* 
  This file contains functions that are used to display error messages to the user.
  The functions are called from the UI files.
*/

import 'package:flutter/material.dart'; // material design
import 'package:another_flushbar/flushbar.dart'; // error popups

class PopupUtils {
  createErrorMessage(context, errorMsg) {
    var errorText = const Color.fromARGB(255, 88, 15, 15);
    var errorBackground = const Color.fromARGB(255, 238, 37, 37);

    // if error message is not a string, convert it to a string
    if (errorMsg.runtimeType != String) {
      errorMsg = errorMsg.toString();
    }
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
      maxWidth: MediaQuery.of(context).size.width * 0.8,
      isDismissible: true,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    ).show(context);
  }

  createSuccessMessage(context, errorMsg) {
    var errorText = const Color.fromARGB(255, 15, 88, 47);
    var errorBackground = const Color.fromARGB(255, 78, 249, 36);

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
