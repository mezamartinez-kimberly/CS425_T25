import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendUtils {
  static String sessionToken = '';

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

  //create a function decode the users first name, last name, email for the profile page and account settings
  static Future<List<String>> getUserData() async {
    const String apiUrl = 'http://10.0.2.2:5000/obtainUserNameEmail';

    // create a post request to the backend with the auth header
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': "Bearer $sessionToken",
        // so connection doesn't close while retrieving data
        "Connection": "Keep-Alive",
      },
    );

    if (response.statusCode == 200) {
      //grab body of the response and convert it to a list 
      final List<dynamic> responseBody = json.decode(response.body);

      //get first name from response body
      String firstName = responseBody[0]['first_name'];

      //get last name from response body
      String lastName = responseBody[0]['last_name'];

      //get email from response body
      String email = responseBody[0]['email'];

      //store strings in an array to return
      List<String> userData = [firstName, lastName, email];

      //return array
      return userData;

    } else{
      //obtaining data failed
      return ["Error, obtaining data failed"];
    }
  }
  
}