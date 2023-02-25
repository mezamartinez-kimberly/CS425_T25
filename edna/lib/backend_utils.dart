import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendUtils {
  static String sessionToken = '';
  static String emailGlobal = '';

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
    const String apiUrl = 'http://192.168.161.137/upc';

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

    if (response.statusCode == 201) {
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
    const String apiUrl = 'http://192.168.161.137/sendOTP';

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
    const String apiUrl = 'http://192.168.161.137/verifyOTP';

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
    const String apiUrl = 'http://192.168.161.137/changePassword';

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
}
