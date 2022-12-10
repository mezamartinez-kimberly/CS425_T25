/* 
==============================
*    Title: profile.dart
*    Author: Julian Fliegler
*    Date: Dec 2022
==============================
*/

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // icons
import 'package:edna/screens/all.dart'; // all screens
import 'package:image_picker/image_picker.dart'; // gallery, camera
import 'package:flutter/services.dart'; // PlatformException
import 'dart:io'; // File data type

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  // vars to use gallery function
  var imageFile;
  ImagePicker imagePicker = ImagePicker();

  // get from gallery
  Future getFromGallery() async {
    try {
      imagePicker = ImagePicker();
      final image = await imagePicker!.pickImage(source: ImageSource.gallery);

      if (image == null) return;
      final imageTemp = File(image.path);

      setState(() {
        imageFile = imageTemp;
        print("update display");
      });
    } on PlatformException catch (e) {
      // todo: display error to screen
      // https://api.flutter.dev/flutter/material/AlertDialog-class.html
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Profile Page',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          // create standard theme for buttons
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                color: Color.fromARGB(255, 5, 47, 53),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
        ),
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
            ),
            body: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  // org children (picture, buttons) in vert array
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment
                        .end, // sticks list of buttons to bottom of screen
                    children: [
                      // gesture detector = respond when clicked
                      // photo and user name
                      GestureDetector(
                        onTap: () {
                          {
                            imageFile == null
                                ? getFromGallery()
                                : print("display selected image");
                            // final InputImage inputImage = InputImage.fromFile(imageFile);

                          }
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              // align icon to left
                              Align(
                                alignment: Alignment
                                    .centerLeft, // doesn't seem to be working
                                child: Icon(Icons.add_a_photo_outlined,
                                    size: 60.0),
                              ),
                              // put user name in flexible fitted box so resizes dynamically
                              Flexible(
                                  child: FittedBox(
                                      fit: BoxFit.fill,
                                      child: Text('FirstName LastName',
                                          style: TextStyle(
                                              fontSize: 25,
                                              color: Colors.black)))),
                            ]),
                      ),
                      const Text('username@email.com'),
                      const SizedBox(height: 70), // space in between widgets
                      GestureDetector(
                          onTap: () {
                            {
                              print("Login");
                            }
                          },
                          // each button is a card that is sized using "sized box"
                          child: Card(
                            color: Color.fromARGB(255, 165, 253, 239),
                            child: SizedBox(
                                height: 70,
                                child: Center(
                                    // sized box contains row of icon and text
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.lock_outline),
                                    Text(' Login Info',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black)),
                                  ],
                                ))),
                          )),
                      GestureDetector(
                          onTap: () {
                            {
                              print("Premium");
                            }
                          },
                          child: Card(
                            color: Color.fromARGB(255, 165, 253, 239),
                            child: SizedBox(
                                height: 70,
                                child: Center(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.star_outline_rounded),
                                    Text(' Premium Content',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black)),
                                  ],
                                ))),
                          )),
                      GestureDetector(
                          onTap: () {
                            {
                              print("Appearance");
                            }
                          },
                          child: Card(
                            color: Color.fromARGB(255, 165, 253, 239),
                            child: SizedBox(
                                height: 70,
                                child: Center(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.brush_outlined),
                                    Text(' Appearance Settings',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black)),
                                  ],
                                ))),
                          )),
                      GestureDetector(
                          onTap: () {
                            {
                              print("Notifs");
                            }
                          },
                          child: Card(
                            color: Color.fromARGB(255, 165, 253, 239),
                            child: SizedBox(
                                height: 70,
                                child: Center(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(CupertinoIcons.bell),
                                    Text(' Notifications',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black)),
                                  ],
                                ))),
                          )),
                      GestureDetector(
                          onTap: () {
                            {
                              print("Support");
                            }
                          },
                          child: Card(
                            color: Color.fromARGB(255, 165, 253, 239),
                            child: SizedBox(
                                height: 70,
                                child: Center(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(CupertinoIcons.question_circle),
                                    Text(' Support',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black)),
                                  ],
                                ))),
                          )),
                      const SizedBox(height: 10), // add padding at bottom
                    ],
                  ),
                ))));
  }
}
