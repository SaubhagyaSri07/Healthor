import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';

  class ProfileScreen extends StatelessWidget {
    const ProfileScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile Screen',
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF007BFF),
        ),
        body: Center(
          child: Text(
            'Profile Screen - Coming Soon!',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ),
      );
    }
  }