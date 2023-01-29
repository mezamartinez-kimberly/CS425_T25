import 'package:edna/screens/all.dart'; // all screens
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();

  // getters
  List<GButton> get bottomNavigationBar => _HomePageState()._navItems;
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final _pageOptions = [
    const CameraPage(),
    PantryPage(
      bottomNavigationBar: HomePage().bottomNavigationBar,
    ),
    const CalendarClass(),
    const StatsPage(),
    const ProfilePage()
  ];

  final List<GButton> _navItems = [
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
  ];

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
          tabs: _navItems,
          selectedIndex: _selectedIndex,
          // update index when user selects tab
          onTabChange: _onNavBarTap),
    );
  }
}
