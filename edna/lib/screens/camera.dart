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

import 'dart:io'; // File data type
import 'package:flutter/material.dart';
import 'package:edna/screens/all.dart'; // all screens
import 'package:image_picker/image_picker.dart'; // gallery, camera
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'; // ocr
import 'package:flutter/services.dart'; // PlatformException
import 'package:google_fonts/google_fonts.dart'; // fonts

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  // variables
  String result = ''; // result of OCR scan
  var imageFile;
  ImagePicker? imagePicker; // ? = nullable
  // todo: parse result of scan
  parseText(String result) {}

  // read text from image
  performTextRecognition() async {
    final InputImage inputImage = InputImage.fromFile(
        imageFile); // convert from File to InputImage -- processImage() only works with InputImage
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
      }
      parseText(result);
    });
  }

  // pick image from gallery
  // Future = can run func async; can only be either completed or uncompleted
  Future getFromGallery() async {
    try {
      // final = runtime constant; must be initialized, and that is the only time it can be assigned to
      // await = make async func appear sync; line won't be executed until pickImage returns value
      final image = await imagePicker!.pickImage(source: ImageSource.gallery);

      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() {
        imageFile = imageTemp;
        performTextRecognition();
      });
    } on PlatformException catch (e) {
      // todo: display error to screen
      // https://api.flutter.dev/flutter/material/AlertDialog-class.html
      print('Failed to pick image: $e');
    }
  }

  // pick image from camera
  Future getFromCamera() async {
    try {
      final image = await imagePicker!.pickImage(source: ImageSource.camera);

      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() {
        imageFile = imageTemp;
        performTextRecognition();
      });
    } on PlatformException catch (e) {
      // todo: display error to screen
      print('Failed to pick image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // must init image picker to be able to use gallery, camera
    imagePicker = ImagePicker();
  }

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
                                  backgroundColor: Colors.blue,
                                  fixedSize: const Size(200, 50),
                                ),
                                onPressed: () {
                                  getFromGallery();
                                },
                                child: const Text("PICK FROM GALLERY")),
                            Container(
                              height: 40.0,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
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
                                leading: Icon(Icons.camera),
                                title: Text(
                                  'RESULT OF SCAN',
                                  textAlign: TextAlign.center,
                                ),
                                trailing: Icon(Icons.more_vert),
                              ),
                              // align in vert array
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
                                      // even Padding On All Sides
                                      padding: const EdgeInsets.all(10.0),
                                      child: SizedBox(
                                        width: 300,
                                        height: 40,
                                        // Accept All button
                                        child: TextButton(
                                          onPressed: () {
                                            // go to pantry page
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //       builder: (context) =>
                                            //           const PantryPage()),
                                            // );
                                          },
                                          style: const ButtonStyle(
                                              backgroundColor:
                                                  MaterialStatePropertyAll(
                                                      Colors.blue)),
                                          child: const Text(
                                            'Accept All',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ))));
  }
}
