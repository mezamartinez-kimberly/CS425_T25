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

RegExp priceExp = RegExp(r'\d{1,2}\.\d{2}'); // price regex
RegExp itemExp = RegExp(r"^[a-zA-Z\s]+"); // item regex

void parseText(List<ReceiptLine> receiptLines) {
  // move prices for bulk items to correct line
  for (var eachLine in receiptLines) {
    print(eachLine.line); // debug

    // if line starts with a number and isn't followed by a character (bulk items)
    if (eachLine.line.startsWith(RegExp(r'^\d(?![a-zA-Z])'))) {
      // get price
      // prices start with 1 or 2 digits, followed by decimal, follow by 2 digits
      priceExp = RegExp(r'\d{1,2}\.\d{2}');
      var priceMatch = priceExp.firstMatch(eachLine.line)?.group(0);

      // if the line contains a price
      if (priceMatch != null) {
        // take price off end of line
        var tempPrice = priceMatch;
        // delete line
        eachLine.line = eachLine.line.replaceFirst(eachLine.line, '').trim();
        // append price to prev line
        receiptLines[receiptLines.indexOf(eachLine) - 1].line += " $tempPrice";
      }
    }
  }

  // separate items and price into diff vars
  for (var eachLine in receiptLines) {
    // get prices
    var priceMatch = priceExp.firstMatch(eachLine.line)?.group(0);
    // get items
    var itemMatch = itemExp.firstMatch(eachLine.line)?.group(0);

    // if line item and a price
    if (priceMatch != null && itemMatch != null) {
      // set vars in each line obj
      eachLine.item = itemMatch;
      eachLine.price = priceMatch;
    }
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  // variables
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
        (line) => (line.id - thisID).abs() <= 1); // within 10 of each other

    // if no match
    if (index == -1) {
      // create new string in obj
      recLine.line = thisText.text.trim();
      // append to list of all lines
      allLines.add(recLine);
      // sort by id (ascending)
      allLines.sort((a, b) => a.id.compareTo(b.id));
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
        // Check if the block is skewed
        if (block.cornerPoints.any((point) => point.x <= 0 || point.y <= 0)) {
          // Reorient the block
          List<Point<int>> newCornerPoints = block.cornerPoints
              .map((point) => Point(max(0, point.x), max(0, point.y)))
              .toList();

          // Create a new block with the reoriented corner points
          TextBlock newBlock = TextBlock(
            text: block.text,
            lines: block.lines,
            boundingBox: block.boundingBox,
            recognizedLanguages: block.recognizedLanguages,
            cornerPoints: newCornerPoints,
          );

          // Extract the text from the reoriented block
          String text = newBlock.text;
          // Do something with the text

        } else {
          // Extract the text from the block
          String text = block.text;
          // Do something with the text

        }
        for (TextLine line in block.lines) {
          matchLinesHorizontally(line); // matches items to prices
        }
      }
      // separates items from prices, removes all other text
      parseText(allLines);
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
                                                    PantryPage(),
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
