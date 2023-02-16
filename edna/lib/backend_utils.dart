import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendUtils {
  static Future<String> registerUser(
      String firstName, String lastName, String email, String password) async {
    const String apiUrl = 'http://192.168.161.137/register';

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
    const String apiUrl = 'http://192.168.161.137/login';
    final Map<String, dynamic> message = {
      'email': email,
      'password': password,
    };
    final String jsonPayload = json.encode(message);

    // send the request to the backend as POST request
    final http.Response response = await http.post(headers: {
      'Content-Type':
          'application/json', // set Content-Type header to application/json
    }, Uri.parse(apiUrl), body: jsonPayload);

    // check the status code for the result
    if (response.statusCode == 201) {
      // Registration was successful
      return "Login successful";
    } else {
      // Registration failed
      return "Login failed";
    }
  }
}