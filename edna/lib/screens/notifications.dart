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

import 'dart:ffi';

import 'package:edna/main.dart';
import 'package:flutter/material.dart';
import 'package:edna/screens/all.dart'; // all screens
import 'package:google_fonts/google_fonts.dart';

import '../backend_utils.dart';

class NotificationsPage extends StatefulWidget {
  //can also turn off prefer_const_constructor under rules and put false so that you dont need these
  const NotificationsPage({Key? key});
  @override
  NotificationsPageState createState() => NotificationsPageState();
}
class NotificationsPageState extends State<NotificationsPage>{
  //expiration notif switch

  String ddValue = '';

  String onOffHolder = '';
  String valueHolder = '';

  refresh() async {
    await getUserPreferences();
    setState(() {});
  }

  //create an initialization function to get user data
  @override
  void initState() {
    super.initState();
    getUserPreferences().then((_) {
    });
  }

  //create a widget for a drop down menu for expiration notification range
  Widget buildDropDownMenu() {

    List<DropdownMenuItem<String>> daysList = ['3 days', '5 days', '7 days', '10 days']
        .map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();

    DropdownMenuItem<String> dropdownValue = daysList[0];
    //DropdownMenuItem<String> dropdownValue = ddValue as DropdownMenuItem<String>;
    
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: DropdownButton<String>(
        value: dropdownValue.value,
        icon: const Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        style: const TextStyle(color: Colors.black),
        underline: Container(
          height: 2,
          color: Colors.black,
        ),
        onChanged: (String? newValue) {
          setState(() {
            ddValue = newValue!;
            print(ddValue);
            //call to udpate range
            updateUserNotificationRange(ddValue);

          });
        },
        items: daysList,
      ),
    );
  }

  //create function to call getUserPreferences
  Future<void> getUserPreferences() async {
    //call /getUserPreferences from backend
    List<String> userPrefList = await BackendUtils.getUserPreferences();
    setState(() {
      onOffHolder = userPrefList[0];    // they are currently stirngs but since its going to be isSwitched need to convert to bool
      valueHolder = userPrefList[1];
      print('before conversion onOffHolder: $onOffHolder');
      //convert to bool by passing into function
      isSwitched = convertStringToBoolSwitch(onOffHolder);
      //convert valueHolder to string
      ddValue = valueHolder;
      //ddValue = addDaysString(valueHolder);
      print('after conversion isSwitched: $isSwitched');
      print('range ddValue: $ddValue');
    }); 
  }
    late bool isSwitched;

  //create a function that will pass in onOffHolder and convert it to a bool
  bool convertStringToBoolSwitch(String onOffHolder) {
    bool switchOr = false;
    if (onOffHolder == 'true') {
      switchOr = true;
      return switchOr;
    }
    else {
     return switchOr;
    }
  }

  //create a function to call updateNotificationOnOff
  Future<void> updateNotificationOnOff(isSwitched) async {
    //cast notifOnOff to string
    String notifOnOffString = convertBoolToString(isSwitched);

    //call /updateNotificationOnOff from backend
    await BackendUtils.updateNotificationOnOff(notifOnOffString);
  }

  //create function to pass a bool and convert it to a string
  String convertBoolToString(bool notifOnOff) {
    String notifOnOffS = '';
    if (notifOnOff == true) {
      notifOnOffS = 'true';
      return notifOnOffS;
    }
    else {
      notifOnOffS = 'false';
      return notifOnOffS;
    }
  }

  //create a function that uses valueHolder and adds " days"
  //  String addDaysString(String numDays) {
  //   String fullString;
  //   if (numDays != '3 days' || numDays != '5 days' || numDays != '7 days' || numDays != '10 days') {
  //     fullString = '$numDays days';
  //   return fullString;
  //   }
  //   else {
  //     fullString = numDays;
  //     return fullString;
  //   }
  // }

  //create function to call updateUserPreferences to update database
  Future<void> updateUserNotificationRange(String notifRange) async {
    //call /updateUserNameEmail from backend
    await BackendUtils.updateUserNotificationRange(notifRange);
    setState(() {
      ddValue = notifRange;
    });
  }

  // create a circular back button thats in the upper left corner
  Widget _buildBackBtn() {
    return Container(
      // push the button down
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
              //expiration notif toggle
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
                  //call to update db
                  updateNotificationOnOff(isSwitched);
                });
              },
              activeTrackColor: const Color(0xFF7D9AE4), 
              activeColor: Colors.white,
            ),
            //notifcation range area
            const SizedBox(height: 30.0),
            Text('Notification Range: $ddValue',
              style: const TextStyle(fontSize: 20.0,
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
            //drop down menu
            buildDropDownMenu(),
          ],
        ),
      ),
      ),
    );
  }
}