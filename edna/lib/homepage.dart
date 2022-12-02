import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      bottomNavigationBar: GNav(
        haptic: true, // haptic feedback
        gap: 8,
        iconSize: 24,
        padding: EdgeInsets.symmetric(
            horizontal: 5, vertical: 20), // navigation bar padding
        tabs: [
          GButton(
            icon: Icons.camera_alt_rounded,
            text: 'Camera',
          ),
          GButton(
            icon: Icons.shopping_basket,
            text: 'Pantry',
          ),
          GButton(
            icon: Icons.calendar_today_rounded,
            text: 'Add',
          ),
          GButton(
            icon: Icons.list_alt,
            text: 'Stats',
          ),
          GButton(
            icon: Icons.person,
            text: 'Profile',
          ),
        ],
      ),
    );
  }
}
