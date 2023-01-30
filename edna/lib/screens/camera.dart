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

import 'dart:io'; // File data type
import 'package:flutter/material.dart';
import 'package:edna/screens/all.dart'; // all screens
import 'package:image_picker/image_picker.dart'; // gallery, camera
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'; // ocr
import 'package:flutter/services.dart'; // PlatformException
import 'package:google_fonts/google_fonts.dart'; // fonts
import 'dart:developer'; // debugging, "inspect"
import 'package:collection/src/iterable_extensions.dart'; // firstWhereOrNull

/* Ref: https://dart.academy/creating-objects-and-classes-in-dart-and-flutter/ */
class ReceiptLine {
  //List<dynamic> idRange;
  int id;
  String line;
  String item;
  String price;

  ReceiptLine({this.id = 0, this.line = "", this.item = "", this.price = ""});
}

void parseText(List<ReceiptLine> receiptLines) {
  for (var line in receiptLines) {
    // separate prices from products
    RegExp exp = RegExp(r'\d{1,2}\.\d{2}');
    var match = exp.firstMatch(line.line);
    // if the line contains a price
    if (match != null) {
      line.price = match.group(0)!;
      line.item = line.line.replaceFirst(line.price, '').trim();
      // remove strings of numbers from item var
      RegExp exp2 = RegExp(r'\d+(\.\d+)?');
      line.item = line.item.replaceAll(exp2, '').trim();
    }
    print("\n" + line.line); // debugging
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  // variables
  // dynamic wholeReceipt; // result of OCR scan
  // String result = '';
  var imageFile;
  ImagePicker? imagePicker; // ? = nullable
  List<ReceiptLine> allLines = [];

  // for debugging
  void printYellow(String text) {
    print('\x1B[33m$text\x1B[0m');
  }

  // ref: https://stackoverflow.com/questions/59920284/how-to-find-an-element-in-a-dart-list
  matchLinesHorizontally(TextLine thisText) {
    // new receipt line object
    final recLine = ReceiptLine();

    // get id of this line
    recLine.id = thisText.boundingBox.center.dy.toInt(); // vertical center
    int thisID = recLine.id;

    // try to match IDs
    var index = allLines.indexWhere(
        (line) => (line.id - thisID).abs() <= 30); // within 10 of each other

    // if no match
    if (index == -1) {
      // create new string in obj
      recLine.line = thisText.text.trim();
      // append to list of all lines
      allLines.add(recLine);
    }
    // if match found
    else {
      // append existing obj
      allLines[index].line += thisText.text.trim();
    }
  }

  // read text from image
  performTextRecognition() async {
    final InputImage inputImage = InputImage.fromFile(
        imageFile); // convert from File to InputImage -- processImage() only works with InputImage
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    setState(() {
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          matchLinesHorizontally(line); // matches items to prices
        }
      }
      parseText(
          allLines); // separates items from prices, removes all other text
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
                                  SizedBox(
                                      width: 300,
                                      height: 400,
                                      // make scrollable
                                      child: Scrollbar(
                                          child: ListView.builder(
                                        itemCount: allLines.length,
                                        itemBuilder: (context, index) {
                                          // don't print empty space
                                          if (allLines[index].item.isNotEmpty &&
                                              allLines[index]
                                                  .price
                                                  .isNotEmpty) {
                                            return Row(
                                              children: <Widget>[
                                                // left align item
                                                Expanded(
                                                  child: Text(
                                                    allLines[index].item,
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                                // right align price
                                                Expanded(
                                                  child: Text(
                                                    allLines[index].price,
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          return Container();
                                        },
                                      ))),

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
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PantryPage(
                                                  bottomNavigationBar:
                                                      const HomePage()
                                                          .bottomNavigationBar,
                                                ),
                                              ),
                                            );
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
