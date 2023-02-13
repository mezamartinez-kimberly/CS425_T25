/*
==============================
*    Title: camera.dart
*    Author: Julian Fliegler
*    Date: Dec 2022
==============================
*/

/* Referenced code:
 - https://stackoverflow.com/questions/49577781/how-to-create-number-input-field-in-flutter
*/

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:edna/screens/all.dart'; // all screens
//import 'package:fast_qr_reader_view/fast_qr_reader_view.dart'; // barcode scanner
import 'package:flutter/services.dart'; // PlatformException
import 'package:google_fonts/google_fonts.dart'; // fonts

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  String _scanBarcode = 'Unknown';
  String _pluCode = "null";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //       debugShowCheckedModeBanner: false,
  //       title: 'Camera Page',
  //       theme: ThemeData(
  //         primarySwatch: Colors.blue,
  //         textTheme:
  //             GoogleFonts.notoSerifTextTheme(Theme.of(context).textTheme),
  //       ),
  //       home: Scaffold(
  //         appBar: AppBar(
  //             title: const Align(
  //           alignment: Alignment.centerLeft,
  //           child: Text('Camera'),
  //         )),
  //         body: Builder(builder: (BuildContext context) {
  //           return Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 50.0),
  //             child: Container(
  //               alignment: Alignment.center,
  //               child: Flex(
  //                   direction: Axis.vertical,
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: <Widget>[
  //                     // barcode button

  //                     // upc text output
  //                     Text('UPC Code: $_scanBarcode\n',
  //                         style: const TextStyle(fontSize: 20)),

  //                     // plu text entry
  //                     TextField(
  //                       onChanged: (text) {
  //                         // get numbers user entered
  //                         _pluCode = text;
  //                       },
  //                       decoration:
  //                           const InputDecoration(labelText: "Enter PLU Code"),
  //                       keyboardType: TextInputType.number,
  //                       inputFormatters: <TextInputFormatter>[
  //                         FilteringTextInputFormatter
  //                             .digitsOnly, // only allow nums
  //                         LengthLimitingTextInputFormatter(
  //                             4), // only allow 4 nums
  //                       ],
  //                     ),
  //                   ]),
  //             ),
  //           );
  //         }),
  //       ));
  // }
//}
