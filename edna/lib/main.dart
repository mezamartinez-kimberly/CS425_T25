<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'homepage.dart';
import 'camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
      //home: Camera(),
    );
=======
import 'dart:io'; // File type
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:developer'; // log statements

void main() {
  // any preprocessing can be done here, such as determining a device location
  //
  // runApp is a Flutter function that runs your Flutter app
  runApp(MaterialApp(home: CameraPage()));
}

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  // Variables
  String result = '';
  var imageFile;
  ImagePicker? imagePicker;

  performImageLabeling() async {
    // convert from File to InputImage (processImage() only works with InputImage)
    final InputImage inputImage = InputImage.fromFile(imageFile);

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    result = '';

    setState(() {
      for (TextBlock block in recognizedText.blocks) {
        final String? txt = block.text;

        for (TextLine line in block.lines) {
          for (TextElement element in line.elements) {
            result += element.text + " ";
          }
        }
        result += "\n\n";
      }
      log('result: $result');
    });
  }

  // get from gallery
  getFromGallery() async {
    PickedFile? pickedFile =
        await imagePicker!.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        performImageLabeling();
      });
    }
  }

  // get from camera
  getFromCamera() async {
    PickedFile? pickedFile =
        await imagePicker!.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        performImageLabeling();
      });
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
          title: const Text("Image Picker"),
        ),
        body: Container(
            child: imageFile == null
                ? Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          //color: Colors.greenAccent,
                          onPressed: () {
                            getFromGallery();
                          },
                          child: const Text("PICK FROM GALLERY"),
                        ),
                        Container(
                          height: 40.0,
                        ),
                        ElevatedButton(
                          //color: Colors.lightGreenAccent,
                          onPressed: () {
                            getFromCamera();
                          },
                          child: const Text("PICK FROM CAMERA"),
                        )
                      ],
                    ),
                  )
                : Container(
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                    ),
                  )));
>>>>>>> Julian-Dev
  }
}
