import 'package:edna/provider.dart';
import 'package:edna/screens/all.dart';
import 'package:flutter/material.dart';
import 'package:edna/backend_utils.dart';

import 'package:edna/dbs/pantry_db.dart'; // pantry db

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  //dark/light mode switch
  bool isSwitched = false;

  Future<List<String>>? userData;

  refresh() async {
    await _getUserData();
    setState(() {});
  }

  //create an initialization function to get user data
  @override
  void initState() {
    super.initState();
    _getUserData().then((_) {});
    WidgetsFlutterBinding.ensureInitialized();
    NotificationService().initNotification();
    tz.initializeTimeZones();
  }

  Widget _buildLogOutButton() {
    return SizedBox(
      //center align

      height: 50,
      width: MediaQuery.of(context).size.width * 0.885,
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
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (ctx) => const LoginPage()),
                (route) => false);
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
    userData = BackendUtils.getUserData();
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
      appBar: AppBar(
        //change text color to black and align the text to the left
        title: const Text('Profile',
            style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto')),
        leadingWidth: 0,
        centerTitle: false,
        // make transparent
        backgroundColor: Colors.transparent,
        // remove shadow
        shadowColor: Colors.transparent,
        elevation: 1,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //card for greeting
              FutureBuilder<List<String>>(
                future: userData,
                builder: (BuildContext context,
                    AsyncSnapshot<List<String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else {
                      final firstName = snapshot.data![0];
                      final lastName = snapshot.data![1];
                      final email = snapshot.data![2];
                      return Center(
                        child: Column(
                          children: [
                            Text(
                              'Hello, $firstName $lastName!',
                              style: const TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AccountSettingsPage()),
                    ).then((value) => setState(() {
                          refresh();
                        }));
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
                      MaterialPageRoute(
                        builder: (context) => const NotificationsPage(),
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
                    NotificationService().makeNotifications();
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
                        MaterialPageRoute(
                          builder: (context) => const FAQsPage(),
                        ));
                  },
                ),
              ),
              const SizedBox(height: 10.0),
              Center(
                child: _buildLogOutButton(),
              )
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
        const AndroidInitializationSettings('logo_foreground2');

    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await notificationsPlugin.initialize(initializationSettings);
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
            'channelId', 'channelName', 'channel description',
            importance: Importance.max));
  }

  Future showNotification({int id = 0, String? title, String? body}) async {
    return notificationsPlugin.show(
        id, title, body, await notificationDetails());
  }

  Future scheduleNotification(
      {int id = 0,
      String? title,
      String? body,
      required DateTime scheduledNotificationDateTime}) async {
    return notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(
          scheduledNotificationDateTime,
          tz.local,
        ),
        await notificationDetails(),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  //create a function that creates the notifications
  Future makeNotifications() async {
    //call backend utils getAllPantry to get all pantry items
    List<Pantry> activePantryItems = await BackendUtils.getAllPantry();
    //late List<Pantry> activePantryItems = Provider.of<PantryProvider>(context, listen: false).activePantryItems;
    List<String> userPrefs =
        await BackendUtils.getUserPreferences();
    String notificationOn = userPrefs[0]; //output is 'true' or 'false' in string
    String notifRange = userPrefs[1]; //ouptut is '3 days' etc in string\

    //extract the numbers in notifRange value and change to int
    notifRange = notifRange.replaceAll(RegExp(r'[^0-9]'), '');
    //convert notifRange to int
    int notifRangeInt = int.parse(notifRange);
    //get the current date
    DateTime today = DateTime.now();

    for (final item in activePantryItems) {
      //subtract the notification range from the expiration date
      DateTime firstDate = item.expirationDate!.subtract(Duration(days: notifRangeInt));
      //check if today falls in between the expiration date and the new date
      if (today.isAfter(firstDate) && today.isBefore(item.expirationDate!)) {
        String name = item.name!;
        String expirDate = DateFormat('MM/dd/yyyy').format(item.expirationDate!);
        String titleContent = 'EDNA $name is expiring soon!';
        String bodyContent = 'Your $name will expire on $expirDate. Consider using it soon!';
        print(titleContent);
        print(bodyContent);
        //show notification
        NotificationService().showNotification(title: titleContent, body: bodyContent);

        int indexValue = notifRangeInt;
        int loopValue = indexValue - 1 ;

        //delay notification by 5 seconds
        await Future.delayed(const Duration(seconds: 5));
        
        //create a variable that takes the days between now and the expiration date
        int daysBetween = item.expirationDate!.difference(today).inDays;

        for (int i = 0; i < daysBetween; i++) {
          //get tomorrows date and add loop value to it with the time being 5pm
          DateTime newDate = DateTime.now().add(Duration(days: i + 1));

          //schedule notification
          NotificationService().scheduleNotification(
              title: titleContent,
              body: bodyContent,
              scheduledNotificationDateTime: newDate);

          print('new notification scheduled for $newDate');
        }
      }
    }
  }
}
