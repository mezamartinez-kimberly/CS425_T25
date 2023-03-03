import 'package:edna/screens/account_settings.dart';
import 'package:edna/screens/all.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  //dark/light mode switch
  bool isSwitched = false;

  Widget _buildLogOutButton() {
    return SizedBox(
      height: 50,
      width: 350,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: const Color(0xFF7D9AE4),
        ),
        onPressed: () {
          //insert log out actions
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
              const SizedBox(height: 40.0),

              // Add a greeting, "Hello, [firstname][lastname]!"
              Center(
                child: Column(
                  children: const [
                    Text(
                      'Hello, Firstname Lastname!',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'useremail@example.com',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30.0),

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
                  leading: const Icon(Icons.palette),
                  title: const Text(
                    'Appearance Settings',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Tap to switch between light and dark mode',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    // switch between modes
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
