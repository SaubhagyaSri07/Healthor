import 'package:flutter/material.dart';
     import 'package:provider/provider.dart';
     import 'package:healthor/providers/symptom_provider.dart';
     import 'package:healthor/screens/main_screen.dart';
     import 'package:healthor/screens/symptom_checker_screen.dart';
     import 'package:healthor/screens/profile_screen.dart';
     import 'package:healthor/screens/book_appointment_screen.dart';
     import 'package:healthor/screens/chatbot_screen.dart';
     import 'package:healthor/screens/report_analysis_screen.dart';
     import 'package:healthor/screens/reminders_screen.dart';
     import 'package:healthor/screens/nearby_doctors_screen.dart';
     import 'package:flutter_dotenv/flutter_dotenv.dart';

     void main() async {
       WidgetsFlutterBinding.ensureInitialized();
       await dotenv.load(fileName: ".env");
       runApp(const HealthorApp());
     }

     class HealthorApp extends StatelessWidget {
       const HealthorApp({super.key});

       @override
       Widget build(BuildContext context) {
         return MultiProvider(
           providers: [
             ChangeNotifierProvider(create: (_) => SymptomProvider()),
           ],
           child: MaterialApp(
             title: 'Healthor',
             theme: ThemeData(
               primarySwatch: Colors.blue,
               visualDensity: VisualDensity.adaptivePlatformDensity,
             ),
             initialRoute: '/',
             onGenerateRoute: (settings) {
               switch (settings.name) {
                 case '/':
                   return MaterialPageRoute(builder: (_) => const MainScreen());
                 case '/symptom_checker':
                   return MaterialPageRoute(builder: (_) => const SymptomCheckerScreen());
                 case '/profile':
                   return MaterialPageRoute(builder: (_) => const ProfileScreen());
                 case '/book_appointment':
                   return MaterialPageRoute(builder: (_) => const BookAppointmentScreen());
                 case '/chatbot':
                   return MaterialPageRoute(builder: (_) => const ChatbotScreen());
                 case '/report_analysis':
                   return MaterialPageRoute(builder: (_) => const ReportAnalysisScreen());
                 case '/reminders':
                   return MaterialPageRoute(builder: (_) => const RemindersScreen());
                 case '/nearby_doctors':
                   return MaterialPageRoute(builder: (_) => const NearbyDoctorsScreen());
                 default:
                   return MaterialPageRoute(
                     builder: (_) => Scaffold(
                       body: Center(child: Text('Route not found: ${settings.name}')),
                     ),
                   );
               }
             },
           ),
         );
       }
     }