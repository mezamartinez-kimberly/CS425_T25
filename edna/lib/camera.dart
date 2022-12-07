// ignore_for_file: avoid_print

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
*/

import 'dart:io'; // File type
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
//import 'dart:developer'; // log statements
import 'package:edna/pantry.dart'; // pantry.dart
import 'package:flutter/services.dart'; // PlatformException

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  // Variables
  String result = '';
  var imageFile;
  ImagePicker? imagePicker;
  //bool _isLoading = false;

  parseText(String result) {}

  performImageLabeling() async {
    // convert from File to InputImage (processImage() only works with InputImage)
    final InputImage inputImage = InputImage.fromFile(imageFile);

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    result = '';

    setState(() {
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          for (TextElement element in line.elements) {
            result += "${element.text} ";
          }
        }
        // todo: add loading indicator
        result += "\n";
        //_isLoading = false;
      }
      parseText(result);
    });
  }

  // get from gallery
  Future getFromGallery() async {
    try {
      final image = await imagePicker!.pickImage(source: ImageSource.gallery);

      if (image == null) return;
      final imageTemp = File(image.path);

      setState(() {
        imageFile = imageTemp;
        //_isLoading = true;
        performImageLabeling();
      });
    } on PlatformException catch (e) {
      // todo: display error to screen
      // https://api.flutter.dev/flutter/material/AlertDialog-class.html
      print('Failed to pick image: $e');
    }
  }

  Future getFromCamera() async {
    try {
      final image = await imagePicker!.pickImage(source: ImageSource.camera);

      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() {
        imageFile = imageTemp;
        //_isLoading = true;
        performImageLabeling();
      });
    } on PlatformException catch (e) {
      // todo: display error to screen
      print('Failed to pick image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }

  // Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Camera View"),
        ),
        body: Container(
            child: imageFile == null
                ? // if no image selected, display buttons
                Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Background color
                            fixedSize: const Size(200, 50),
                          ),
                          onPressed: () {
                            getFromGallery();
                          },
                          child: const Text("PICK FROM GALLERY"),
                        ),
                        Container(
                          height: 40.0,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Background color
                            fixedSize: const Size(200, 50),
                          ),
                          onPressed: () {
                            getFromCamera();
                          },
                          child: const Text("PICK FROM CAMERA"),
                        )
                      ],
                    ),
                  )
                : // if image selected, display text read
                Center(
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const ListTile(
                            //leading: Icon(Icons.album),
                            title: Text(
                              'RESULT OF SCAN',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // align children in vert array
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              // not working, doesn't see if value for isLoading changes during runtime
                              // Center(
                              //   child: _isLoading
                              //       ? const Text("Loading Complete")
                              //       : const CircularProgressIndicator(),
                              // ),
                              // box containing read text
                              SizedBox(
                                width: 300,
                                height: 400,
                                // make scrollable
                                child: Scrollbar(
                                    child: SingleChildScrollView(
                                        // todo: make scrollbar always visible
                                        child: Text(
                                  // prints the read text
                                  result,
                                  style: const TextStyle(fontSize: 20),
                                ))),
                              ),
                              // box containing "accept" button
                              Padding(
                                  // Even Padding On All Sides
                                  padding: const EdgeInsets.all(10.0),
                                  child: SizedBox(
                                    width: 300,
                                    height: 40,
                                    child: TextButton(
                                      onPressed: () {
                                        /* go to pantry */
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const PantryPage()),
                                        );
                                      },
                                      style: const ButtonStyle(
                                          // ERR: not centering
                                          alignment: Alignment.center,
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.lightBlue)),
                                      child: const Text(
                                        'Accept All',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 20),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                        ],
                      ),
                    ),
                  )));
  }
}
