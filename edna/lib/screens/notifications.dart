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

import '../backend_utils.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsPage extends StatefulWidget {
  //can also turn off prefer_const_constructor under rules and put false so that you dont need these
  const NotificationsPage({Key? key});
  @override
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage> {
  //create an initialization function to get user data
  @override
  void initState() {
    super.initState();
    getUserPreferences().then((_) {});
  }

  //create variables for switch and dropdown
  bool isSwitched = false;

  List<String> rangeDays = ['3 days', '5 days', '7 days', '10 days'];
  String baseVal = '10 days';

  //create function to call getUserPreferences
  Future<void> getUserPreferences() async {
    //call /getUserPreferences from backend
    List<String> userPrefList = await BackendUtils.getUserPreferences();
    setState(() {
      String onOffHolder = userPrefList[
          0]; // they are currently strings but since its going to be isSwitched need to convert to bool
      String rangeHolder = userPrefList[1];
      print(
          'before conversion onOffHolder: $onOffHolder'); //on is true, off is false i think
      //convert to bool by passing into function
      isSwitched = convertStringToBoolSwitch(onOffHolder);
      //convert valueHolder to string
      baseVal = rangeHolder;
      //ddValue = addDaysString(valueHolder);
      print('after conversion isSwitched: $isSwitched');
      print('range ddValue: $baseVal');
    });
  }

  //create a function that will pass in onOffHolder and convert it to a bool
  bool convertStringToBoolSwitch(String onOffHolder) {
    bool switchOr = false;
    if (onOffHolder == 'true') {
      switchOr = true;
      return switchOr;
    } else {
      return switchOr;
    }
  }

  //create function to pass a bool and convert it to a string
  String convertBoolToString(bool notifOnOff) {
    String notifOnOffS = '';
    if (notifOnOff == true) {
      notifOnOffS = 'true';
      return notifOnOffS;
    } else {
      notifOnOffS = 'false';
      return notifOnOffS;
    }
  }

  //create a function to call updateNotificationOnOff
  Future<void> updateNotificationOnOff(isSwitched) async {
    //cast notifOnOff to string
    String notifOnOffString = convertBoolToString(isSwitched);

    //call /updateNotificationOnOff from backend
    await BackendUtils.updateNotificationOnOff(notifOnOffString);
  }

  //create function to call updateUserPreferences to update database
  Future<void> updateUserNotificationRange(String notifRange) async {
    //call /updateUserNameEmail from backend
    await BackendUtils.updateUserNotificationRange(notifRange);
    setState(() {
      baseVal = notifRange;
    });
  }

//

  Widget _buildBackBtn() {
    return Container(
      // pushh the button down
      padding: const EdgeInsets.only(top: 10),
      alignment: Alignment.centerLeft,

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
          onPressed: () => Navigator.pop(context),
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
            const Padding(
              padding: EdgeInsets.only(
                  top: 20,
                  left: 70), // Adjust the top value as per your requirement
              child: Text(
                'Notification Settings',
                style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
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
                contentPadding: const EdgeInsets.all(0),
                title: const Text(
                  'Expiration Notifications',
                  style: TextStyle(
                    fontSize: 20.0,
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
              Text(
                'Notification Range: $baseVal',
                style: const TextStyle(
                  fontSize: 20.0,
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
              const SizedBox(height: 20.0),
              DropdownButton(
                value: baseVal,
                onChanged: (value) {
                  setState(() {
                    baseVal = value.toString();
                    //call to update db
                    updateUserNotificationRange(baseVal);
                    print('update value is $baseVal');
                  });
                },
                items: rangeDays.map((itemone) {
                  return DropdownMenuItem(
                    value: itemone,
                    child: Text(itemone),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
