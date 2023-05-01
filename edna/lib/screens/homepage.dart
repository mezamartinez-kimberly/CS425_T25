/* 
==============================
*    Title: homepage.dart
*    Author: John Watson
*    Date: Dec 2022
==============================
*/

import 'package:edna/screens/all.dart'; // all screens
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

// Following this tutorial: https://api.flutter.dev/flutter/material/NavigationBar-class.html
class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final _pageOptions = [
    CameraPage(),
    const PantryPage(),
    const CalendarClass(),
    const TreePage(),
    const ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pageOptions
            .elementAt(_currentIndex), // move to page at selected index
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int newIndex) {
          setState(() {
            HapticFeedback.lightImpact(); // add haptic feedback

            _currentIndex = newIndex;
          });
        },
        backgroundColor: Colors.transparent,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.camera_alt),
            icon: Icon(Icons.camera_alt_outlined),
            label: 'Camera',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.shopping_basket),
            icon: Icon(Icons.shopping_basket_outlined),
            label: 'Shelf',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.calendar_month),
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Calendar',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.park),
            icon: Icon(Icons.park_outlined),
            label: 'Tree',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
