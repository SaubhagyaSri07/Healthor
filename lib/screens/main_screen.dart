import 'package:flutter/material.dart';
  import 'home_screen.dart';
  import 'profile_screen.dart';
  import 'appointments_screen.dart';
  import 'settings_screen.dart';

  class MainScreen extends StatefulWidget {
    const MainScreen({super.key});

    @override
    State<MainScreen> createState() => _MainScreenState();
  }

  class _MainScreenState extends State<MainScreen> {
    int _selectedIndex = 0;

    static const List<Widget> _screens = [
      HomeScreen(),
      ProfileScreen(),
      AppointmentsScreen(),
      SettingsScreen(),
    ];

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: const Color(0xFF007BFF),
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Appointments'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      );
    }
  }