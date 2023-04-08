/* 
==============================
*    Title: faqs.dart
*    Author: Kimberly Meza Martinez
*    Date: Feb 2023
==============================
*/
import 'package:flutter/material.dart';
import 'package:edna/screens/all.dart'; // all screens
import 'package:google_fonts/google_fonts.dart';

class FAQsPage extends StatefulWidget {
  const FAQsPage({Key? key});

  @override
  FAQsPageState createState() => FAQsPageState();
}

class FAQsPageState extends State<FAQsPage>{

  // create a circular back button thats in the upper left corner
  Widget _buildBackBtn() {
    return Container(
      // pushh the button down
      padding: const EdgeInsets.only(top: 10),
      alignment: Alignment.topLeft,
      // wrap in circular button
      child: SizedBox(
        height: 35,
        width: 35,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(0),
            backgroundColor: const Color(0xFF7D9AE4),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Container(
            alignment: Alignment.center,
            child: const Padding(
              padding: EdgeInsets.only(left: 7),
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: <Widget>[
            _buildBackBtn(),
            const Text('         FAQs',
              style: TextStyle(fontSize: 30.0,
                color: Colors.black, 
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
      ),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20.0),
        ),
      ),
    );
  }
}