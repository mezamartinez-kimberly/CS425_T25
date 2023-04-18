import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:edna/screens/all.dart';
import 'package:edna/provider.dart';
import 'package:provider/provider.dart';
import 'package:edna/dbs/pantry_db.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:edna/backend_utils.dart';


//function run when app opens, store and schedule them 
//have function run in background 

class PushNotification {
  PushNotification({
    this.title,
    this.body,
  });
  String? title;
  String? body;
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  print("Handling a background message: ${message.messageId}");
}


//create a class that will hold the state of the notifications
class NotificationsClassState extends State{
  late final FirebaseMessaging _messaging;

  int notificationOn = 0;
  int notifRange = 0;

  //create a function that calls the getUserPreferences function
  Future<void> createNotifications() async {
    //get the current date
    DateTime today = DateTime.now();

    print('in createNotif functio');

    // create an instance of BackendUtils
    BackendUtils backendUtils = BackendUtils();

    //call the getUserNotifications function
    List<String> data = await backendUtils.getUserPreferences();
    setState(() {
      notificationOn = data[0] as int;
      notifRange = data[1] as int;
    });

    print(notificationOn);

    //if the notificationOn is 1 then call the getAllPantry function
    if (notificationOn == 1) {
      // ignore: use_build_context_synchronously
      late List<Pantry> activePantryItems = Provider.of<PantryProvider>(context, listen: false).activePantryItems;

      //access expiration dates
      for (final item in activePantryItems){

        print('in for loop');

        //subtract the notification range from the expiration date
        DateTime firstDate = item.expirationDate!.subtract(Duration(days: notifRange));
        //check if today falls in between the expiration date and the new date
        if (today.isAfter(firstDate) && today.isBefore(item.expirationDate!)){
          //if it does then create and send a notification containing the item name and expiration date


          //create a notification
          PushNotification notification = PushNotification(
            title: item.name,
            body: item.expirationDate.toString(),
          );

          //send the notification

        }
      }
    }

  }


  //create a function that initializes the firebase app, and configures the messaging to receive notifications
  void registerNotification() async {
    //Initialize the Firebase app
    await Firebase.initializeApp();
    //Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      // handling the received notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print(
            'Message title: ${message.notification?.title}, body: ${message.notification?.body}');
        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );

        setState(() {
          //go to calendar page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CalendarClass()),
        );
          // _notificationInfo = notification;
          // _totalNotifications++;
        });
      });
    } else {
      print('User declined or has not accepted permission');
    }
}

// For handling notification when the app is in terminated state
  checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        // dataTitle: initialMessage.data['title'],
        // dataBody: initialMessage.data['body'],
      );

      setState(() {
        //go to calendar page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CalendarClass()),
        );
        // _notificationInfo = notification;
        // _totalNotifications++;
      });
    }
  }

  @override
  void initState() {
    //_totalNotifications = 0;
    registerNotification();
    checkForInitialMessage();
    createNotifications().then((_) {
    });

    // For handling notification when the app is in background
    // but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        // dataTitle: message.data['title'],
        // dataBody: message.data['body'],
      );

      setState(() {
        //go to calendar page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CalendarClass()),
        );

        // _notificationInfo = notification;
        // _totalNotifications++;
      });
    });

    super.initState();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
