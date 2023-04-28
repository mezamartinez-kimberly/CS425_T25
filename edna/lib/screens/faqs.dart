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

  final questions = [
  {
    'question': 'What is the purpose of EDNA?',
    'answer': 'EDNA strives to help you decrease your food waste and save money while doing so. With our notifications and tree growing capabilities we try to remind and encourage you to eat your food before it goes bad!'
  },
  {
    'question': 'How do I add a PLU code?',
    'answer': 'You can add a PLU code when you go into the Camera Page or the Pantry Page and click on the + sign. You can then fill in the fields including the PLU codes.'
  },
  {
    'question': 'How do I find items in the Calendar?',
    'answer': 'To find events in the Calendar, you flip through the weeks or months until you see a dot under a date indicating an item is going to expire on that date.'
  },
  {
    'question': 'How do I grow my tree?',
    'answer': 'Your tree grows when you click on an item to mark as consumed and when prompted if the item is expired, you click on the no button. This is because the tree is a fun incentive for not wasting food and eating it before it expires!'
  },
  {
    'question': 'How do I reset my password?',
    'answer': 'To change your password simply go into the Profile Page, click on Account Settings, then fill in your email under the Change Password field. This will send an email verification code that you can enter when prompted. After which if it is correct, it will allow you to go onto the next page where you can change your password.'
  },
];

@override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: <Widget>[
            _buildBackBtn(),
            const Text(
              '         FAQs',
              style: TextStyle(
                fontSize: 30.0,
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index]['question'];
              final answer = questions[index]['answer'];
              return ExpansionTile(
                title: Text(question!),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(answer!),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}