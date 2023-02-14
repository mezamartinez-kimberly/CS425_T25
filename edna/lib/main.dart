import 'package:edna/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:edna/screens/all.dart'; // all screens
import 'package:edna/utils/database_helper.dart'; // database helper

void main() async {
  runApp(const MyApp());
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
