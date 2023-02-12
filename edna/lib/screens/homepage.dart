/* 
==============================
*    Title: homepage.dart
*    Author: John Watson
*    Date: Dec 2022
==============================
*/

import 'package:edna/screens/all.dart'; // all screens
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _pageOptions = [
    const CameraPage(),
    const PantryPage(),
    const CalendarClass(),
    const StatsPage(),
    const ProfilePage()
  ];

// Following the basic structure of the tutorial at:
// https://pub.dev/packages/google_nav_bar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: _pageOptions
            .elementAt(_selectedIndex), // move to page at selected index
      ),
      bottomNavigationBar: GNav(
        haptic: true, // haptic feedback
        gap: 8,
        iconSize: 24,
        padding: const EdgeInsets.symmetric(
            horizontal: 15, vertical: 20), // navigation bar padding
        tabs: [
          GButton(
            icon: Icons.camera_alt_rounded,
            text: 'Camera',
            iconActiveColor: Colors.lightBlue,
            backgroundColor: Colors.lightBlue.withOpacity(0.2),
          ),
          GButton(
            icon: Icons.shopping_basket,
            text: 'Pantry',
            iconActiveColor: Colors.red,
            backgroundColor: Colors.red.withOpacity(0.2),
          ),
          GButton(
            icon: Icons.calendar_today_rounded,
            text: 'Calendar',
            iconActiveColor: Colors.orange,
            backgroundColor: Colors.orange.withOpacity(0.2),
          ),
          GButton(
            icon: Icons.list_alt,
            text: 'Stats',
            iconActiveColor: Colors.purple,
            backgroundColor: Colors.purple.withOpacity(0.2),
          ),
          GButton(
            icon: Icons.account_circle,
            text: 'Profile',
            iconActiveColor: Colors.grey,
            backgroundColor: Colors.grey.withOpacity(0.2),
          ),
        ],
        selectedIndex: _selectedIndex,
        // update index when user selects tab
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
