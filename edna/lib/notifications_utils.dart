// import 'package:flutter/material.dart';
// import 'dart:collection';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:edna/calendar_utils.dart';
// import 'package:edna/provider.dart';
// import 'package:provider/provider.dart';
// import 'package:edna/dbs/pantry_db.dart';

// class PushNotification {
//   PushNotification({
//     this.title,
//     this.body,
//   });
//   String? title;
//   String? body;
// }

// //create a class that will hold the state of the notifications
// class NotificationsClassState extends State{
//   late final FirebaseMessaging _messaging;


//   //create a function that initializes the firebase app, and configures the messaging to receive notifications
//   void registerNotification() async {
//     //Initialize the Firebase app
//     await Firebase.initializeApp();
//     //Instantiate Firebase Messaging
//     _messaging = FirebaseMessaging.instance;

//     // On iOS, this helps to take the user permissions
//     NotificationSettings settings = await _messaging.requestPermission(
//       alert: true,
//       badge: true,
//       provisional: false,
//       sound: true,
//     );
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted permission');
//       // handling the received notifications
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         // Parse the message received
//         PushNotification notification = PushNotification(
//           title: message.notification?.title,
//           body: message.notification?.body,
//         );

//         setState(() {
//           _notificationInfo = notification;
//           _totalNotifications++;
//         });
//       });
//     } else {
//       print('User declined or has not accepted permission');
//     }
// }



//   @override
//   dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
// }
