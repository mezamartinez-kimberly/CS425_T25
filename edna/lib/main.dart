import 'package:edna/backend_utils.dart';
import 'package:edna/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:edna/screens/all.dart'; // all screens
import 'package:edna/provider.dart'; // provider
import 'package:intl/intl.dart';
import 'package:path/path.dart'; // path
import 'package:provider/provider.dart'; // provider
import 'package:edna/dbs/pantry_db.dart'; // pantry db

//ref: https://www.geeksforgeeks.org/background-local-notifications-in-flutter/

//-----------------NOTIFICATIONS-----------------
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

void main() async {
  // //------------BELOW IS THE CODE FOR NOTIFICATIONS----------------
  // // needed if you intend to initialize in the `main` function
  // WidgetsFlutterBinding.ensureInitialized();
  //tz.initializeTimeZones();
  // Workmanager().initialize(
  //     // The top level function, aka callbackDispatcher
  //     callbackDispatcher,
  //     // If enabled it will post a notification whenever
  //     // the task is running. Handy for debugging tasks
  //     isInDebugMode: false
  // );
  // // Periodic task registration
  // Workmanager().registerPeriodicTask(
  //   "2",
  //   //This is the value that will be
  //   // returned in the callbackDispatcher
  //   "simplePeriodicTask",
  //   // When no frequency is provided
  //   // the default 15 minutes is set.
  //   // Minimum frequency is 15 min.
  //   // Android will automatically change
  //   // your frequency to 15 min
  //   // if you have configured a lower frequency.
  //   //frequency: const Duration(days: 1),
  //   frequency: const Duration(minutes: 15),
  // );
  // //-------ABOVE IS THE CODE FOR NOTIFICATIONS---------------

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

  // //create function to get active pantry items
  // Future<List<Pantry>> getActivePantryItems(BuildContext context) async {
  //   //use provider class to get active pantry items
  //   late List<Pantry> activePantryItems = Provider.of<PantryProvider>(context, listen: false).activePantryItems;
  //   return activePantryItems;
  // }

  // //create a function that gets the user preferences
  // Future<List<String>> getUserPreferences() async {
  //   //get the user preferences from the backend
  //   List<String> userPrefs = await BackendUtils.getUserPreferences();
  //   return userPrefs;
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/camera': (context) => CameraPage(),
      },
      home: const LoginPage(),
    );
  }

  createErrorMessage(context, errorMsg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Container(
        alignment: Alignment.topCenter,
        height: 15.0,
        child: Center(
          child: Text(
            errorMsg,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 55, 55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(
        horizontal: 30.0,
        vertical: 15,
      ),
    ));
  }
}
