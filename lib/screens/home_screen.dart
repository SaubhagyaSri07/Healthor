import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import '../widgets/feature_card.dart';

  class HomeScreen extends StatelessWidget {
    const HomeScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF007BFF),
          title: Text(
            'Healthor',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Healthor!',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your smart healthcare companion for affordable and accessible care.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    FeatureCard(
                      icon: Icons.health_and_safety,
                      title: 'Symptom Checker',
                      onTap: () {
                        Navigator.pushNamed(context, '/symptom_checker');
                      },
                    ),
                    FeatureCard(
                      icon: Icons.calendar_today,
                      title: 'Book Appointment',
                      onTap: () {
                        Navigator.pushNamed(context, '/book_appointment');
                      },
                    ),
                    FeatureCard(
                      icon: Icons.chat,
                      title: 'AI Chatbot',
                      onTap: () {
                        Navigator.pushNamed(context, '/chatbot');
                      },
                    ),
                    FeatureCard(
                      icon: Icons.description,
                      title: 'Report Analysis',
                      onTap: () {
                        Navigator.pushNamed(context, '/report_analysis');
                      },
                    ),
                    FeatureCard(
                      icon: Icons.alarm,
                      title: 'Medicine Reminders',
                      onTap: () {
                        Navigator.pushNamed(context, '/reminders');
                      },
                    ),
                    FeatureCard(
                      icon: Icons.location_on,
                      title: 'Nearby Doctors',
                      onTap: () {
                        Navigator.pushNamed(context, '/nearby_doctors');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }