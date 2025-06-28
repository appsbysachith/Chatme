import 'package:five/screens/contactprofilescreen.dart';
import 'package:five/screens/contactscreen.dart';
import 'package:five/screens/homescreen.dart';
import 'package:flutter/material.dart';

class Bottomnavigationscreen extends StatefulWidget {
  const Bottomnavigationscreen({super.key});

  @override
  State<Bottomnavigationscreen> createState() => _BottomnavigationscreenState();
}

class _BottomnavigationscreenState extends State<Bottomnavigationscreen> {
  int currentindex = 0;
  final List<Widget> _screens = [
    Homescreen(),
    Contactscreen(),
    ContactProfileScreen(),
  ]; //these are screens defined

  void _onTap(int index) {
    setState(() {
      currentindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[currentindex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF24786D),
        unselectedItemColor: Colors.grey,
        currentIndex: currentindex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin),
            label: "contacts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "settings",
          ),
        ],
      ),
    );
  }
}
