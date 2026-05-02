import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home_page.dart';
import 'auth/auth_gate.dart';
import 'pages/feedback_page.dart';
import 'pages/concours/concours_page.dart';
import 'pages/influencer/influenceurs_page.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/places_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rsymjvtwfxkevpqzgytb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJzeW1qdnR3ZnhrZXZwcXpneXRiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk0NjMwODEsImV4cCI6MjA4NTAzOTA4MX0.ozca8-zqUuaRhgUj9LrBlTfgbwoyQ-Ey9uLX4gCZYc8',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  title: 'PeeMart',
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    fontFamily: 'Swansea',
    useMaterial3: true,
  ),

  initialRoute: '/auth',
  

  routes: {
    '/home': (context) => const HomePage(),
    '/auth': (context) => const AuthGate(),
    '/feedback': (context) => const FeedbackPage(),
    '/concours': (context) => const ConcoursPage(),
    '/influencers': (context) => const InfluenceursPage(),
    '/admin': (context) => const AdminDashboardPage(),
    '/places': (context) => const PlacesPage(),
  },
  
);
  }
}
