import 'package:edna/camera.dart';
import 'package:edna/pantry.dart';
import 'package:edna/calendar.dart';
import 'package:edna/statistics.dart';
import 'package:edna/profile.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // move to page at selected index
      body: Center(
        child: _pageOptions.elementAt(_selectedIndex), //New
      ),
      bottomNavigationBar: GNav(
        haptic: true, // haptic feedback
        gap: 8,
        iconSize: 24,
        padding: const EdgeInsets.symmetric(
            horizontal: 5, vertical: 20), // navigation bar padding
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
            icon: Icons.person,
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
