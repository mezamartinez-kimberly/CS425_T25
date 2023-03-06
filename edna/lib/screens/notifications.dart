/* 
==============================
*    Title: notifications.dart
*    Author: Kimberly Meza Martinez
*    Date: Feb 2023
==============================
*/
/* Referenced code for drop down button:
* https://www.geeksforgeeks.org/flutter-dropdownbutton-widget/
*/

import 'package:flutter/material.dart';
import 'package:edna/screens/all.dart'; // all screens
import 'package:google_fonts/google_fonts.dart';

class NotificationsPage extends StatefulWidget {
  //can also turn off prefer_const_constructor under rules and put false so that you dont need these
  const NotificationsPage({Key? key});
  @override
  NotificationsPageState createState() => NotificationsPageState();
}
class NotificationsPageState extends State<NotificationsPage>{
  //expiration notif switch
  bool isSwitched = false;
  //drop down value
  String dropDownValue = '1 days';

  // NotificationsList = List<String>['3 Days', '5 Days', '7 Days', '10 Days']
  //                 .map<DropdownMenuItem<String>>((String value) {
  //               return DropdownMenuItem<String>(
  //                 value: value,
  //                 child: Text(
  //                   value,
  //                   style: const TextStyle(fontSize: 30),
  //                 ),
  //               );
  //             }).toList(),

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
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: <Widget>[
            _buildBackBtn(),
            const Text('       Notification Settings',
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
          //expiration notif toggle
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: <Widget>[
            SwitchListTile(
              contentPadding:  const EdgeInsets.all(0),
              title: const Text('Expiration Notifications',
                style: TextStyle(fontSize: 20.0,
                  color: Colors.black, 
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              value: isSwitched,
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                });
              },
              activeTrackColor: Color(0xFF7D9AE4), 
              activeColor: Colors.white,
            ),
            //notifcation range area
            const SizedBox(height: 30.0),
            const Text('Notification Range',
              style: TextStyle(fontSize: 20.0,
                color: Colors.black, 
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 10.0),
            const Text(
              'When an expiring food item falls in this range you’ll get a notification.',
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.normal,
                color: Color.fromARGB(255, 63, 61, 61),

              ),
            ),
            const SizedBox(
              height: 50,
            ),
            DropdownButton<String>(
              value: dropDownValue,
              items: <String>['3 Days', '5 Days', '7 Days', '10 Days']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 30),
                  ),
                );
              }).toList(),
              // Step 5.
              onChanged: (String? newValue) {
                setState(() {
                  dropDownValue = newValue!;
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Selected Value: $dropDownValue',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      ),
    );
  }
}