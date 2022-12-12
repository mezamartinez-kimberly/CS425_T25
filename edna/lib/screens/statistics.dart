import 'package:flutter/material.dart';
import 'package:edna/screens/all.dart'; // all screens
import 'package:google_fonts/google_fonts.dart'; // fonts

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  StatsPageState createState() => StatsPageState();
}

class StatsPageState extends State<StatsPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Camera Page',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          textTheme:
              GoogleFonts.notoSerifTextTheme(Theme.of(context).textTheme),
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Statistics'),
          ),
        ));
  }
}
