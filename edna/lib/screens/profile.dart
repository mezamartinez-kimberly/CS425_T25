import 'package:edna/provider.dart';
import 'package:edna/screens/all.dart';
import 'package:flutter/material.dart';
import 'package:edna/backend_utils.dart';


import 'package:edna/dbs/pantry_db.dart'; // pantry db

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  //dark/light mode switch
  bool isSwitched = false;

  String firstName = "";
  String lastName = "";
  String email = "";

  refresh() async {
    await _getUserData();
    setState(() {});
  }

  //create an initialization function to get user data
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    NotificationService().initNotification();
    _getUserData().then((_) {
    });
  }

  Widget _buildLogOutButton() {
    return SizedBox(
      height: 50,
      width: 350,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8.0),
          backgroundColor: const Color(0xFF7D9AE4),
        ),
        onPressed: () {
          //insert log out actions
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
          _logOut().then((_) {
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute( builder: (ctx) => const LoginPage()), (route) => false);
          });
        },
        child: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  //function to get user data from backend
  Future<void> _getUserData() async {
    //get user data from backend
    List<String> userData = await BackendUtils.getUserData();
    setState(() {
      firstName = userData[0];
      lastName = userData[1];
      email = userData[2];
    });
  }

  //function to call logout from backend
  Future<void> _logOut() async {
    //call logout from backend
    await BackendUtils.logoutUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20.0),

              //card for greeting
              SizedBox(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Hello, $firstName $lastName!',
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20.0),

              // Account Settings Card
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  leading: const Icon(Icons.person),
                  title: const Text(
                    'Account Settings',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Change your Username, Email, and Password',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    // Navigate to the account settings page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AccountSettingsPage(),
                      
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10.0),

              // Notification Settings Card
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  leading: const Icon(Icons.notifications),
                  title: const Text(
                    'Notification Settings',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Choose your notification preferences',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    // Navigate to the notification settings page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsPage(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10.0),

              // Appearance Settings Card
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  leading: const Icon(Icons.notifications),
                  title: const Text(
                    'Tap to receive notifications',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Since our notifications are scheduled, we have implemented a way to show you the notifications you would have received.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    //call backend utils getAllPantry to get all pantry items
                    //List<Pantry> activePantryItems = await BackendUtils.getAllPantry();
                    late List<Pantry> activePantryItems = Provider.of<PantryProvider>(context, listen: false).activePantryItems;
                    List<String> userPrefs = await BackendUtils.getUserPreferences();
                    String notificationOn = userPrefs[0];  //output is 'true' or 'false' in string
                    String notifRange = userPrefs[1];    //ouptut is '3 days' etc in string\

                    //extract the numbers in notifRange value and change to int
                    notifRange = notifRange.replaceAll(RegExp(r'[^0-9]'), '');
                    //convert notifRange to int
                    int notifRangeInt = int.parse(notifRange);
                    //get the current date
                    DateTime today = DateTime.now();
                    for (final item in activePantryItems){
                      print(activePantryItems.length);
                      //subtract the notification range from the expiration date
                      DateTime firstDate = item.expirationDate!.subtract(Duration(days: notifRangeInt));
                      //check if today falls in between the expiration date and the new date
                      if (today.isAfter(firstDate) && today.isBefore(item.expirationDate!)){
                        String name = item.name!;
                        String expirDate = DateFormat('MM/dd/yyyy').format(item.expirationDate!);
                        String? titleContent = 'EDNA, $name is expiring soon!';
                        String? bodyContent = 'Your $name will expire on $expirDate. Consider using it soon!';
                        //show notification
                        NotificationService().showNotification(title: titleContent, body: bodyContent);
                      }
                    }
                  },
                ),
              ),

              const SizedBox(height: 10.0),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  leading: const Icon(Icons.question_mark_outlined),
                  title: const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Tips and Tricks',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    // Navigate to the FAQs page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FAQsPage(),
                      )
                    );
                  },
                ),
              ),
              const SizedBox(height: 10.0),
              _buildLogOutButton(),
            ],
          ),
        ),
      ),
    );
  }
}
//----------- notifications code below
class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid);
    await notificationsPlugin.initialize(initializationSettings);
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName', 'channel description',
            importance: Importance.max));
  }

  Future showNotification(
      {int id = 0, String? title, String? body}) async {
    return notificationsPlugin.show(
        id, title, body, await notificationDetails());
  }
}