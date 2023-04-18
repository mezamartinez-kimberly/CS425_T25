import 'package:edna/backend_utils.dart';
import 'package:edna/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:edna/screens/all.dart'; // all screens
import 'package:another_flushbar/flushbar.dart'; // snackbars
import 'package:another_flushbar/flushbar_helper.dart'; // snackbars
import 'package:another_flushbar/flushbar_route.dart'; // snackbars
import 'package:edna/provider.dart'; // provider
import 'package:path/path.dart'; // path
import 'package:provider/provider.dart'; // provider
import 'package:edna/dbs/pantry_db.dart'; // pantry db

//ref: https://www.geeksforgeeks.org/background-local-notifications-in-flutter/

//-----------------NOTIFICATIONS-----------------
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
 
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    // initialise the plugin of flutterlocalnotifications.
    FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();
     
    // app_icon needs to be a added as a drawable
    // resource to the Android head project.
    var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
     
    // initialise settings for both Android and iOS device.
    var settings = InitializationSettings(android: android);
    flip.initialize(settings);
    showNotificationWithDefaultSound(flip);
    return Future.value(true);
  });
}

int notificationOn = 0;
int notifRange = 0;


//create a function that calls the getUserPreferences function
//and then checks if the notificationOn variable is set to 1
//if it is, then call the _showNotificationWithDefaultSound function
//if it is not, then do nothing
// Future<void> checkNotifPref() async {
//   BackendUtils backendUtils = BackendUtils();

//   List<String> userPrefs = await backendUtils.getUserPreferences();
//   notificationOn = int.parse(userPrefs[0]);
//   notifRange = int.parse(userPrefs[1]);

//   if (notificationOn == 1) {
//     checkNotifDate();
//   }
// }
// //create a function that obtains active pantry items, loops them and subtracts the notification range from the expiry date and then checks if today falls within those dates, and if it does then it creates calls the _showNotificationWithDefaultSound function
// Future<void> checkNotifDate() async {
//   //get the current date
//   DateTime today = DateTime.now();
//   //create a flip variable to store 


//   // ignore: use_build_context_synchronously
//   late List<Pantry> activePantryItems = Provider.of<PantryProvider>(context, listen: false).activePantryItems;

//   for (final item in activePantryItems){
//     //subtract the notification range from the expiration date
//         DateTime firstDate = item.expirationDate!.subtract(Duration(days: notifRange));
//         //check if today falls in between the expiration date and the new date
//         if (today.isAfter(firstDate) && today.isBefore(item.expirationDate!)){
//           //if it does then create and send a notification containing the item name and expiration date
//           _showNotificationWithDefaultSound();
//         }
//   }

// }

 
Future showNotificationWithDefaultSound(flip) async {
  BackendUtils backendUtils = BackendUtils();

  List<String> userPrefs = await backendUtils.getUserPreferences();
  notificationOn = int.parse(userPrefs[0]);
  notifRange = int.parse(userPrefs[1]);

  if (notificationOn == 1) {
    //get the current date
    DateTime today = DateTime.now();

    //get the active pantry items
    // ignore: use_build_context_synchronously
    late List<Pantry> activePantryItems = Provider.of<PantryProvider>(context, listen: false).activePantryItems;

    for (final item in activePantryItems){
      //subtract the notification range from the expiration date
          DateTime firstDate = item.expirationDate!.subtract(Duration(days: notifRange));
          //check if today falls in between the expiration date and the new date
          if (today.isAfter(firstDate) && today.isBefore(item.expirationDate!)){
            //if it does then create and send a notification containing the item name and expiration date
            // Show a notification after every 15 minute with the first
            // appearance happening a minute after invoking the method
            var androidPlatformChannelSpecifics =  const AndroidNotificationDetails(
                'channel id',
                'channel name',
                'channel description',
                importance: Importance.max,
                priority: Priority.high
            );
            // initialise channel platform for both Android and iOS device.
            var platformChannelSpecifics = NotificationDetails(
                android: androidPlatformChannelSpecifics
            );
            await flip.show(0, '${item.name} is expiring soon!', 
              'It expires on ${item.expirationDate}. Remember to use it before it expires to grow your tree and save the planet!',
              platformChannelSpecifics, payload: 'Default_Sound'
            );
        }
     }
  }
}

//--------------above is the code for notifications----------------

void main() async {
  //------------BELOW IS THE CODE FOR NOTIFICATIONS----------------
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
     
      // The top level function, aka callbackDispatcher
      callbackDispatcher,
     
      // If enabled it will post a notification whenever
      // the task is running. Handy for debugging tasks
      isInDebugMode: true
  );
  // Periodic task registration
  Workmanager().registerPeriodicTask(
    "2",
     
    //This is the value that will be
    // returned in the callbackDispatcher
    "simplePeriodicTask",
     
    // When no frequency is provided
    // the default 15 minutes is set.
    // Minimum frequency is 15 min.
    // Android will automatically change
    // your frequency to 15 min
    // if you have configured a lower frequency.
    frequency: const Duration(days: 1),
  );
  //-------ABOVE IS THE CODE FOR NOTIFICATIONS---------------

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PantryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }

  createErrorMessage(context, errorMsg) {
    var errorText = const Color.fromARGB(255, 88, 15, 15);
    var errorBackground = const Color.fromARGB(255, 238, 37, 37);
    print(" CONTEXT = $context");
    // if error message is not a string, convert it to a string
    if (errorMsg.runtimeType != String) {
      errorMsg = errorMsg.toString();
    }
    Flushbar(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      message: errorMsg,
      messageSize: 25,
      messageColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : errorText,
      duration: const Duration(seconds: 3),
      backgroundColor: errorBackground,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      borderRadius: BorderRadius.circular(30.0),
      maxWidth: MediaQuery.of(context).size.width * 0.8,
      isDismissible: true,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    ).show(context);
  }

  createSuccessMessage(context, errorMsg) {
    var errorText = Color.fromARGB(255, 15, 88, 47);
    var errorBackground = Color.fromARGB(255, 78, 249, 36);

    Flushbar(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      message: errorMsg,
      messageSize: 25,
      messageColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : errorText,
      duration: const Duration(seconds: 3),
      backgroundColor: errorBackground,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      borderRadius: BorderRadius.circular(30.0),
    ).show(context);
  }
}
