import 'dart:convert';
import 'package:edna/dbs/pantry_db.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class BackendUtils {
  static String sessionToken = '';
  static String emailGlobal = '';

  static Future<String> registerUser(
      String firstName, String lastName, String email, String password) async {
    const String apiUrl = 'http://10.0.2.2:5000/register';

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
    const String apiUrl = 'http://10.0.2.2:5000/login';
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

// // Create a upc get function to get the upc data
  static Future<String> getUpcData(String upc) async {
    const String apiUrl = 'http://10.0.2.2:5000/upc';

    // create a map called "message" that contains the data to be sent to the backend
    final Map<String, dynamic> message = {
      'upc': upc,
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

    if (response.statusCode == 200) {
      // grab the rest of the body
      final Map<String, dynamic> responseBody = json.decode(response.body);
      String name = responseBody['name'];
      // Registration was successful
      return name;
    } else {
      // Registration failed
      return "UPC not found";
    }
  }

// create a function to sent the smail adress to the backend
  static Future<String> sendOTPEmail(String email) async {
    const String apiUrl = 'http://10.0.2.2:5000/sendOTP';

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
    const String apiUrl = 'http://10.0.2.2:5000/verifyOTP';

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
    const String apiUrl = 'http://10.0.2.2:5000/changePassword';

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

// // Create a upc get function to get the upc data
  static Future<String> addPantry(Pantry pantryItem) async {
    const String apiUrl = 'http://10.0.2.2:5000/addPantry';

    // create a map called "message" that contains the data to be sent to the backend
    final Map<String, dynamic> message = {
      'name': pantryItem.name,
      'date_added': pantryItem.dateAdded.toString(),
      'upc': pantryItem.upc,
      'plu': pantryItem.plu,
      'quantity': pantryItem.quantity,
      'location': pantryItem.storageLocation,
      'is_delete': pantryItem.isDeleted,
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      return "Item added to pantry";
    } else {
      return "Item not added to pantry";
    }
  }

  static Future<List<Pantry>> getAllPantry() async {
    const String apiUrl = 'http://10.0.2.2:5000/getAllPantry';

    // create a get request to the backend with the auth header
    final http.Response response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': "Bearer $sessionToken",
        // so connection doesn't close while retrieving data
        "Connection": "Keep-Alive",
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

        // print the enitre contents of the pantry item
        print(pantryItem.name);

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

  static Future<String> updatePantryItem(Pantry pantryItem) async {
    const String apiUrl = 'http://10.0.2.2:5000/updatePantryItem';

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

    if (response.statusCode == 201) {
      return "Pantry item updated successfully.";
    } else {
      return "Error updating pantry item.";
    }
  }
}
