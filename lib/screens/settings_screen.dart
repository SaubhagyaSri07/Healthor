import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';

  class SettingsScreen extends StatelessWidget {
    const SettingsScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Settings',
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF007BFF),
        ),
        body: Center(
          child: Text(
            'Settings Screen - Coming Soon!',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ),
      );
    }
  }