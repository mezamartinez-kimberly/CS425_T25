/*
==============================
*    Title: camera.dart
*    Author: Julian Fliegler
*    Date: Dec 2022
==============================
*/

/* Referenced code:
 - https://medium.com/@brenda.wong/optical-character-recognition-and-how-you-can-use-it-in-your-flutter-app-c79e12ee1bf5
 - https://medium.com/unitechie/flutter-tutorial-image-picker-from-camera-gallery-c27af5490b74
 - https://educity.app/flutter/how-to-pick-an-image-from-gallery-and-display-it-in-flutter

 https://stackoverflow.com/questions/58655810/dart-range-operator
*/

import 'dart:async';
import 'dart:io'; // File data type
import 'dart:math'; // Point class
import 'package:flutter/material.dart';
import 'package:edna/screens/all.dart'; // all screens
import 'package:path/path.dart'; // join()
import 'package:image_picker/image_picker.dart'; // gallery, camera
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'; // barcode scanner
import 'package:flutter/services.dart'; // PlatformException
import 'package:google_fonts/google_fonts.dart'; // fonts
import 'dart:developer'; // debugging, "inspect"
import 'package:collection/src/iterable_extensions.dart'; // firstWhereOrNull

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  CameraPageState createState() => CameraPageState();
}

// ref: https://pub.dev/packages/flutter_barcode_scanner/example
class CameraPageState extends State<CameraPage> {
  // variables
  // var imageFile;
  // ImagePicker? imagePicker; // ? = nullable
  String _scanBarcode = 'Unknown';
  String _pluCode = "null";

  @override
  void initState() {
    super.initState();
    // must init image picker to be able to use gallery, camera
    // imagePicker = ImagePicker();
  }

  // continuous scan
  // Future<void> startBarcodeScanStream() async {
  //   FlutterBarcodeScanner.getBarcodeStreamReceiver(
  //           '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
  //       .listen((barcode) => print(barcode));
  // }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.DEFAULT);
      print(barcodeScanRes);
      // look up scanned code
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  Future<void> queryPLU() async {
    //print(_pluCode);
  }

  // Future<void> scanBarcodeFromImage() async {
  //   String barcodeScanRes;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
  //         '#ff6666', 'Cancel', true, ScanMode.BARCODE);
  //     print(barcodeScanRes);
  //     // look up scanned code
  //   } on PlatformException {
  //     barcodeScanRes = 'Failed to get platform version.';
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;

  //   setState(() {
  //     _scanBarcode = barcodeScanRes;
  //   });
  // }

  // for debugging
  void printYellow(String text) {
    print('\x1B[33m$text\x1B[0m');
  }

  // pick image from gallery
  // Future = can run func async; can only be either completed or uncompleted
  // Future getFromGallery() async {
  //   try {
  //     // final = runtime constant; must be initialized, and that is the only time it can be assigned to
  //     // await = make async func appear sync; line won't be executed until pickImage returns value
  //     final image = await imagePicker!.pickImage(source: ImageSource.gallery);

  //     if (image == null) return;
  //     final imageTemp = File(image.path);
  //     setState(() {
  //       imageFile = imageTemp;
  //       scanBarcodeFromImage();
  //     });
  //   } on PlatformException catch (e) {
  //     // todo: display error to screen
  //     // https://api.flutter.dev/flutter/material/AlertDialog-class.html
  //     print('Failed to pick image: $e');
  //   }
  // }

  // pick image from camera
  // Future getFromCamera() async {
  //   try {
  //     final image = await imagePicker!.pickImage(source: ImageSource.camera);

  //     if (image == null) return;
  //     final imageTemp = File(image.path);
  //     setState(() {
  //       imageFile = imageTemp;
  //     });
  //   } on PlatformException catch (e) {
  //     // todo: display error to screen
  //     print('Failed to pick image: $e');
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   // must init image picker to be able to use gallery, camera
  //   imagePicker = ImagePicker();
  // }

  // widget UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Camera Page',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme:
              GoogleFonts.notoSerifTextTheme(Theme.of(context).textTheme),
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Camera View"),
          ),
          // builder = stateless utility widget
          body: Builder(builder: (BuildContext context) {
            return Container(
                alignment: Alignment.center,
                child: Padding(
                    padding: EdgeInsets.all(50),
                    child: Flex(
                        direction: Axis.vertical,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                              onPressed: () => scanBarcodeNormal(),
                              child: const Text('Start barcode scan')),
                          Text('PLU Code : $_scanBarcode\n',
                              style: TextStyle(fontSize: 20)),
                          // ref: https://stackoverflow.com/questions/49577781/how-to-create-number-input-field-in-flutter
                          TextField(
                            onChanged: (text) {
                              // get numbers user entered
                              _pluCode = text;
                            },
                            decoration:
                                InputDecoration(labelText: "Enter PLU Code"),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly, // only allow nums
                              LengthLimitingTextInputFormatter(4), // only allow 4 nums
                            ],
                          ),
                          // Text('PLU Code : $_pluCode\n',
                          //     style: TextStyle(fontSize: 20))
                        ])));
          }),
        )); // if image selected, display text read
  }
}
