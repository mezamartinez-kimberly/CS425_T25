/* This file is the main file of the app. It is the first file that is run when the app is started. It is responsible for creating the app and displaying the login page. 
*/

import 'package:flutter/material.dart'; // material design
import 'package:edna/screens/all.dart'; // all screens
import 'package:edna/provider.dart'; // provider
import 'package:provider/provider.dart'; // provider

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PantryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
