import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:edna/screens/all.dart';
import 'package:edna/provider.dart';
import 'package:provider/provider.dart';
import 'package:edna/dbs/pantry_db.dart';

import 'package:edna/backend_utils.dart';



//import 'package:rxdart/rxdart.dart';

//to do
//use local notifications plugin to send notifications
// add a background function that will run a function every 24 hrs to check if a new item falls within range and send notifications

// class NotificationApi{
//   static final _notifications = FlutterLocalNotificationsPlugin();
//   static final onNotifications = BehaviorSubject<String?>();

//   static Future _notficationDetails() async{
//     return const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'channel id',
//         'channel name',
//         'channel description',
//         importance: Importance.max,
//       ),
//     );
//   }

//   static Future init({bool initiScheduled = true}) async{

//     final android = AndroidInitializationSettings('@mipmap/ic_launcher');
//     final settings = const InitializationSettings(android: android);


//     await _notifications.initialize(
//      settings,
//      onSelectNotification: (payload) async{
//       onNotifications.add(payload);
//      },
//     );
//   }

//   static Future showNotification({
//     int id = 0,
//     String? title,
//     String? body,
//     String? payload,
//   }) async =>
//     _notifications.show(
//       id,
//       title,
//       body,
//       await NotificationDetails(),
//       payload: payload,
//     );
// }