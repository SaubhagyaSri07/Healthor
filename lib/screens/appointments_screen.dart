import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';

  class AppointmentsScreen extends StatelessWidget {
    const AppointmentsScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Appointments',
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF007BFF),
        ),
        body: Center(
          child: Text(
            'Appointments Screen - Coming Soon!',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ),
      );
    }
  }