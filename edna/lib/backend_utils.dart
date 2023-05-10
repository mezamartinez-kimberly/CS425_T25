/* 
==============================
*    Title: backend_utils.dart
*    Author: All
*    Date: March 2023
==============================
*/

import 'dart:convert';
import 'dart:ffi';
import 'package:edna/dbs/pantry_db.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // DateFormat

// global variables
bool firstTimeScan = true; // to prevent multiple calls from a single scan

class BackendUtils {
  static String sessionToken = '';
  static String emailGlobal = '';

  static Future<String> registerUser(
      String firstName, String lastName, String email, String password) async {
    const String apiUrl = 'http://192.168.0.211:5000/register';

    // create a map called "message" that contains the data to be sent to the backend
    final Map<String, dynamic> message = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
    };

    // convert the map to a JSON string
    final String jsonPayload = json.encode(message);

    // send the request to the backend as POST request
    final http.Response response = await http.post(headers: {
      'Content-Type':
          'application/json', // set Content-Type header to application/json
    }, Uri.parse(apiUrl), body: jsonPayload);

    // check the status code for the result
    if (response.statusCode == 201) {
      // Registration was successful
      return "Registration successful";
    } else {
      // Registration failed
      return "Email already exists";
    }
  }

  // create a function to log the user in
  // this will need to change the state of the app and return the user to the home screen
  static Future<String> loginUser(String email, String password) async {
    const String apiUrl = 'http://192.168.0.211:5000/login';
    final Map<String, dynamic> message = {
      'email': email,
      'password': password,
    };
    final String jsonPayload = json.encode(message);

    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonPayload,
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      sessionToken = responseBody['session_token'];

      return "Login successful";
    } else {
      return "Login failed";
    }
  }

  // Create a upc get function to get the upc data
  static Future<dynamic> getUpcData(String upc) async {
    const String apiUrl = 'http://192.168.0.211:5000/upc';

    // create a map called "message" that contains the data to be sent to the backend
    final Map<String, dynamic> message = {
      'upc': upc,
    };

    // convert the map to a JSON string
    final String jsonPayload = json.encode(message);

    // send the request to the backend as POST request
    if (firstTimeScan == true) {
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': "Bearer $sessionToken",
          'Content-Type': 'application/json',
        },
        body: jsonPayload,
      );

      if (response.statusCode == 200) {
        firstTimeScan = false; // set flag to prevent multiple calls
        // wait 5 seconds before resetting the flag
        Future.delayed(const Duration(seconds: 5), () {
          firstTimeScan = true;
        });

        // grab the rest of the body
        final Map<String, dynamic> responseBody = json.decode(response.body);
        String name = responseBody['name'];

        // name found from UPC
        return name;
      } else {
        // UPC not found
        return "UPC not found";
      }
    } else {
      return null;
    }
  }

  // Create a function that on sumbit changes the visibilty of the pantry items added in the Camera Page
  static Future<http.Response> changeVisibility() async {
    const String apiUrl = "http://192.168.0.211:5000/changeVisibility";

    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': "Bearer $sessionToken",
        'Content-Type': 'application/json',
      },
    );

    return response;
  }

// create a function to sent the smail adress to the backend
  static Future<String> sendOTPEmail(String email) async {
    const String apiUrl = 'http://192.168.0.211:5000/sendOTP';

    emailGlobal = email;

    final Map<String, dynamic> message = {
      'email': email,
    };

    // convert the map to a JSON string
    final String jsonPayload = json.encode(message);

    // send the request to the backend as POST request
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonPayload,
    );

    if (response.statusCode == 201) {
      // Email sent was successful
      return "Email sent successfully";
    } else {
      // Email doesn't exist in db
      return "Email not registered";
    }
  }

// Create a function to verify the OTP
  static Future<String> verifyOTP(String otp) async {
    const String apiUrl = 'http://192.168.0.211:5000/verifyOTP';

    final Map<String, dynamic> message = {
      'email': emailGlobal,
      'otp': otp,
    };

    // convert the map to a JSON string
    final String jsonPayload = json.encode(message);

    // send the request to the backend as POST request
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonPayload,
    );

    if (response.statusCode == 200) {
      // Email sent was successful
      return "OTP is correct";
    } else if (response.statusCode == 402) {
      return "OTP is incorrect";
    } else {
      return "Email not registered";
    }
  }

  static Future<String> changePassword(String password) async {
    const String apiUrl = 'http://192.168.0.211:5000/changePassword';

    final Map<String, dynamic> message = {
      'email': emailGlobal,
      'password': password,
    };

    // convert the map to a JSON string
    final String jsonPayload = json.encode(message);

    // send the request to the backend as POST request
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonPayload,
    );

    if (response.statusCode == 200) {
      // Email sent was successful
      return "New Password set";
    } else if (response.statusCode == 401) {
      return "New Password cant be the same as old password";
    } else {
      return "Email not registered";
    }
  }

// Create a upc get function to get the upc data
  static Future<http.Response> addPantry(Pantry pantryItem) async {
    const String apiUrl = 'http://192.168.0.211:5000/addPantry';

    // create a map called "message" that contains the data to be sent to the backend
    final Map<String, dynamic> message = {
      'id': pantryItem.id,
      'name': pantryItem.name,
      'date_added': pantryItem.dateAdded?.toIso8601String(),
      'expiration_date': pantryItem.expirationDate?.toIso8601String(),
      'upc': pantryItem.upc,
      'plu': pantryItem.plu,
      'quantity': pantryItem.quantity,
      'location': pantryItem.storageLocation,
      'is_delete': pantryItem.isDeleted,
      'is_visible_in_pantry': pantryItem.isVisibleInPantry,
    };

    // convert the map to a JSON string
    final String jsonPayload = json.encode(message);

    // send the request to the backend as POST request
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': "Bearer $sessionToken",
        'Content-Type': 'application/json',
      },
      body: jsonPayload,
    );

    // if (response.statusCode == 200 || response.statusCode == 201) {
    //   return "Item added to pantry";
    // } else {
    //   return "Item not added to pantry";
    // }

    return response;
  }

  static Future<List<Pantry>> getAllPantry() async {
    const String apiUrl = 'http://192.168.0.211:5000/getAllPantry';

    // create a get request to the backend with the auth header
    final http.Response response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': "Bearer $sessionToken",
        'Connection': 'keep-alive',
      },
    );

    if (response.statusCode == 200) {
      // grab the body of the response and convert it to a list of maps
      final List<dynamic> responseBody = json.decode(response.body);

      //define a list of pantry items
      List<Pantry> pantryList = [];

      // loop through the list of maps and convert each map to a pantry item
      for (var item in responseBody) {
        // create a pantry item from the map
        Pantry pantryItem = Pantry.fromMap(item);

        // add the pantry item to the list
        pantryList.add(pantryItem);
      }
      // return the list of pantry items
      return pantryList;
    } else {
      // Registration failed
      return [];
    }
  }

  static Future<http.Response> updatePantryItem(Pantry pantryItem) async {
    const String apiUrl = 'http://192.168.0.211:5000/updatePantryItem';

    // use the pantry item to create a map
    final Map<String, dynamic> pantryMap = pantryItem.toMap();

    // convert the map to a JSON string
    final String jsonString = json.encode(pantryMap);

    // create a post request to the backend with the auth header and JSON message
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': "Bearer $sessionToken",
        'Content-Type': 'application/json',
      },
      body: jsonString,
    );

    // if (response.statusCode == 201) {
    //   return "Pantry item updated successfully.";
    // } else {
    //   return "Error updating pantry item.";
    // }

    return response;
  }

// create a function called add expiration data
  static Future<dynamic> addExpirationData(Pantry pantryItem) async {
    const String apiUrl = 'http://192.168.0.211:5000/addExpirationData';

    // from the pantry item extract the upc, plu, date added and dateRemoved and zip them into a json map
    final Map<String, dynamic> message = {
      'upc': pantryItem.upc,
      'plu': pantryItem.plu,
      'location': pantryItem.storageLocation,
      'date_added': pantryItem.dateAdded?.toIso8601String(),
      'date_removed': pantryItem.expirationDate?.toIso8601String(),
    };

    // create a post request to the backend with the auth header
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': "Bearer $sessionToken",
        'Content-Type': 'application/json',
      },
      body: json.encode(message),
    );

    return response;
  }

  // delete all database items
  // for debugging
  static Future<String> deleteAll() async {
    const String apiUrl = 'http://192.168.0.211:5000/delete_all';

    // create a delete request to the backend with the auth header
    final http.Response response = await http.delete(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': "Bearer $sessionToken",
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return "Database successfully cleared..";
    } else {
      return "Error: ${response.body}.";
    }
  }

// Add points to the user
  static Future<String> addPoints() async {
    const String apiUrl = 'http://192.168.0.211:5000/addPoints';

    // create a post request to the backend with the auth header and JSON message
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': "Bearer $sessionToken",
      },
    );

    if (response.statusCode == 201) {
      return "Points added successfully.";
    } else {
      return "Error adding points.";
    }
  }

// retreive the points from the backend
  static Future<int> getPoints() async {
    const String apiUrl = 'http://192.168.0.211:5000/getPoints';

    // create a post request to the backend with the auth header and JSON message
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': "Bearer $sessionToken",
      },
    );

    // cast the response into an integer if successful
    if (response.statusCode == 200) {
      // parse the json in the response body and return the leaderboard points
      Map<String, dynamic> response_data =
          Map<String, dynamic>.from(jsonDecode(response.body));

      int points = response_data['leaderboard_points'];

      return points;
    } else {
      return 0;
    }
  }

  static Future<String> deletePantryItem(Pantry pantryItem) async {
    const String apiUrl = 'http://192.168.0.211:5000/deletePantryItem';

    // create a map called "message" that contains the data to be sent to the backend
    final Map<String, dynamic> message = {
      'date_added': pantryItem.dateAdded?.toIso8601String(),
    };

    // convert the map to a JSON string
    final String jsonPayload = json.encode(message);

    // send the request to the backend as POST request with auth header and JSON message
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': "Bearer $sessionToken",
        'Content-Type': 'application/json',
      },
      body: jsonPayload,
    );

    if (response.statusCode == 201) {
      return "Pantry item deleted successfully.";
    } else {
      return "Error deleting pantry item.";
    }
  }

  //create a function to decode the users first name, last name, email for the profile page and account settings
  static Future<List<String>> getUserData() async {
    const String apiUrl = 'http://192.168.0.211:5000/obtainUserNameEmail';

    // create a post request to the backend with the auth header
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': "Bearer $sessionToken",
        // so connection doesn't close while retrieving data
        "Connection": "Keep-Alive",
      },
    );

    // check the status code for the result
    if (response.statusCode == 200) {
      //convert response body into a List<string> using jsonDecode
      Map<String, dynamic> userData =
          Map<String, dynamic>.from(jsonDecode(response.body));

      //final List<String> userData = jsonDecode(response.body);

      //get first name from response body
      String firstName = userData['first_name'];

      //get last name from response body
      String lastName = userData['last_name'];

      //get email from response body
      String email = userData['email'];

      //create a list of the user data
      List<String> userDataList = [firstName, lastName, email];

      //return the list
      return userDataList;
    } else {
      // return failed
      return ["Failed to obtain user data"];
    }
  }

  //create a function to use the logout route in the backend
  static Future<String> logoutUser() async {
    const String apiUrl = 'http://192.168.0.211:5000/logout';

    // create a post request to the backend with the auth header
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': "Bearer $sessionToken",
      },
    );

    // check the status code for the result
    if (response.statusCode == 200) {
      // return successful
      return "Logout successful";
    } else {
      // return failed
      return "Logout failed";
    }
  }

  //create a function to update the users first name, last name, email for the profile page and account settings
  //need to handle error where you click the back button and it doesnt update the name on the profile page
  static Future<String> updateUserNameEmail(
      String firstName, String lastName, String email) async {
    const String apiUrl = 'http://192.168.0.211:5000/updateUserNameEmail';

    // create a map called "message" that contains the data to be sent to the backend
    final Map<String, dynamic> message = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    };

    // convert the map to a JSON string
    final String jsonPayload = json.encode(message);

    // send the request to the backend as POST request with auth header and JSON message
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonPayload,
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      sessionToken = responseBody['session_token'];

      return "Update successful";
    } else {
      return "Update failed";
    }
  }

  //create a function to update the users first name
  static Future<String> updateFirstName(String firstName) async {
    const String apiUrl = 'http://192.168.0.211:5000/updateFirstName';

    // create a map called "message" that contains the data to be sent to the backend
    final Map<String, dynamic> message = {'first_name': firstName};

    // convert the map to a JSON string
    final String jsonPayload = json.encode(message);

    // send the request to the backend as POST request with auth header and JSON message
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': "Bearer $sessionToken",
        'Content-Type': 'application/json',
      },
      body: jsonPayload,
    );

    if (response.statusCode == 201) {
      return "Update First Name successful";
    } else {
      return "Update First Name failed";
    }
  }

  //create a function to update the users last name
  static Future<String> updateLastName(String lastName) async {
    const String apiUrl = 'http://192.168.0.211:5000/updateLastName';

    // create a map called "message" that contains the data to be sent to the backend
    final Map<String, dynamic> message = {
      'last_name': lastName,
    };

    // convert the map to a JSON string
    final String jsonPayload = json.encode(message);

    // send the request to the backend as POST request with auth header and JSON message
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': "Bearer $sessionToken",
        'Content-Type': 'application/json',
      },
      body: jsonPayload,
    );

    if (response.statusCode == 201) {
      return "Update Last Name successful";
    } else {
      return "Update Last Name failed";
    }
  }

  //create a function to update the users last name
  static Future<String> updateEmail(String email) async {
    const String apiUrl = 'http://192.168.0.211:5000/updateEmail';

    // create a map called "message" that contains the data to be sent to the backend
    final Map<String, dynamic> message = {
      'email': email,
    };

    // convert the map to a JSON string
    final String jsonPayload = json.encode(message);

    // send the request to the backend as POST request with auth header and JSON message
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': "Bearer $sessionToken",
        'Content-Type': 'application/json',
      },
      body: jsonPayload,
    );

    if (response.statusCode == 201) {
      return "Update Email successful";
    } else {
      return "Update Email failed";
    }
  }

  //create a function to obtain the users preferences
  static Future<List<String>> getUserPreferences() async {
    const String apiUrl =
        'http://192.168.0.211:5000/obtainNotificationPreferences';

    // create a post request to the backend with the auth header
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': "Bearer $sessionToken",
        // so connection doesn't close while retrieving data
        "Connection": "Keep-Alive",
      },
    );

    // check the status code for the result
    if (response.statusCode == 200) {
      //convert response body into a List<string> using jsonDecode
      Map<String, dynamic> userPreferences =
          Map<String, dynamic>.from(jsonDecode(response.body));

      //get is_notifications_on from response body
      String isNotificationsOn = userPreferences['is_notifications_on'];

      //get notification_range from response body
      String notificationRange = userPreferences['notification_range'];

      //create a list of the user data
      List<String> userPreferencesList = [isNotificationsOn, notificationRange];

      //return the list
      return userPreferencesList;
    } else {
      // return failed
      return ["Failed to obtain user preferences"];
    }
  }

  //create a function that gets if the user has notifications on
  static Future<String> getIsNotificationsOn() async {
    const String apiUrl = 'http://192.168.0.211:5000/getIsNotificationsOn';

    // create a post request to the backend with the auth header
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': "Bearer $sessionToken",
        // so connection doesn't close while retrieving data
        "Connection": "Keep-Alive",
      },
    );

    // check the status code for the result
    if (response.statusCode == 200) {
      //convert response body into a List<string> using jsonDecode
      Map<String, dynamic> userPreferences =
          Map<String, dynamic>.from(jsonDecode(response.body));

      //get is_notifications_on from response body
      String isNotificationsOn = userPreferences['is_notifications_on'];

      //return the list
      return isNotificationsOn;
    } else {
      // return failed
      return "Failed to obtain isNotificationsOn";
    }
  }

  //create funtion to update the users preferences
  static Future<String> updateUserPreferences(
      Int isNotificationsOn, Int notificationRange) async {
    const String apiUrl = 'http://192.168.0.211:5000/updateUserPreferences';

    // create a map called "message" that contains the data to be sent to the backend
    final Map<String, dynamic> message = {
      'is_notifications_on': isNotificationsOn,
      'notification_range': notificationRange,
    };

    // convert the map to a JSON string
    final String jsonPayload = json.encode(message);

    // send the request to the backend as POST request with auth header and JSON message
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $sessionToken',
        'Content-Type': 'application/json',
      },
      body: jsonPayload,
    );

    if (response.statusCode == 201) {
      return "Update successful";
    } else {
      return "Update failed";
    }
  }

  //create function to update the users isNotificationOn preference
  static Future<String> updateNotificationOnOff(String isNotificationOn) async {
    const String apiUrl = 'http://192.168.0.211:5000/updateNotificationOnOff';

    // create a map called "message" that contains the data to be sent to the backend
    final Map<String, dynamic> message = {
      'is_notifications_on': isNotificationOn,
    };

    // convert the map to a JSON string
    final String jsonPayload = json.encode(message);

    // send the request to the backend as POST request with auth header and JSON message
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $sessionToken',
        'Content-Type': 'application/json',
      },
      body: jsonPayload,
    );

    if (response.statusCode == 201) {
      return "Update successful";
    } else {
      return "Update failed";
    }
  }

  //create function to update the users notification range
  static Future<String> updateUserNotificationRange(
      String notificationRange) async {
    const String apiUrl = 'http://192.168.0.211:5000/updateNotificationRange';

    // create a map called "message" that contains the data to be sent to the backend
    final Map<String, dynamic> message = {
      'notification_range': notificationRange,
    };

    // convert the map to a JSON string
    final String jsonPayload = json.encode(message);

    // send the request to the backend as POST request with auth header and JSON message
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $sessionToken',
        'Content-Type': 'application/json',
      },
      body: jsonPayload,
    );

    if (response.statusCode == 201) {
      return "Update successful";
    } else {
      return "Update failed";
    }
  }

  //create a function to get if it is the users first login
  static Future<String> getIsFirstLogin() async {
    const String apiUrl = 'http://192.168.0.211:5000/getIsFirstLogin';

    // create a post request to the backend with the auth header
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': "Bearer $sessionToken",
        // so connection doesn't close while retrieving data
        "Connection": "Keep-Alive",
      },
    );

    // check the status code for the result
    if (response.statusCode == 200) {
      //convert response body into a List<string> using jsonDecode
      Map<String, dynamic> isFirstLogin =
          Map<String, dynamic>.from(jsonDecode(response.body));

      //get is_first_login from response body
      String isFirstLoginString =
          isFirstLogin['is_first_login'] ? "true" : "false";

      //return
      return isFirstLoginString;
    } else {
      // return failed
      return "Failed to obtain is first login";
    }
  }
//127.0.0.1:5000 for emulator and diff for phone
}
