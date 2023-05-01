import 'package:edna/backend_utils.dart';
import 'package:edna/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:edna/screens/all.dart'; // all screens
import 'package:another_flushbar/flushbar.dart'; // snackbars
import 'package:another_flushbar/flushbar_helper.dart'; // snackbars
import 'package:another_flushbar/flushbar_route.dart'; // snackbars
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
    var errorText = const Color.fromARGB(255, 15, 88, 47);
    var errorBackground = const Color.fromARGB(255, 78, 249, 36);

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
