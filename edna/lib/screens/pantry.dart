/* 
==============================
*    Title: pantry.dart
*    Author: Julian Fliegler
*    Date: Dec 2022
==============================
*/

/* Referenced code:
* https://api.flutter.dev/flutter/widgets/ListView-class.html
*/

import 'package:flutter/material.dart';
import 'package:edna/screens/all.dart';
import 'package:google_fonts/google_fonts.dart'; // fonts

class PantryPage extends StatefulWidget {
  const PantryPage({super.key});

  @override
  PantryPageState createState() => PantryPageState();
}

class PantryPageState extends State<PantryPage> {
  // todo: populate with actual data
  final List<String> entries = List<String>.filled(15, 'Item');
  // color theme
  MyTheme myTheme = const MyTheme();
  late MaterialColor myBlue =
      myTheme.createMaterialColor(const Color(0xFF69B9BB));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Camera Page',
        theme: ThemeData(
          primarySwatch: Colors.red,
          textTheme:
              GoogleFonts.notoSerifTextTheme(Theme.of(context).textTheme),
        ),
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Pantry'),
            ),
            body: ListView.separated(
              // equal padding alla round
              padding: const EdgeInsets.all(10),
              itemCount: entries.length,
              itemBuilder: (BuildContext context, int index) {
                // use column so can add food categories later
                return Column(
                  children: <Widget>[
                    Container(
                        alignment: Alignment.center,
                        height: 50,
                        color: Color.fromARGB(255, 227, 227, 227),
                        child: Text('${entries[index]} $index')),
                  ],
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            )));
  }
}
