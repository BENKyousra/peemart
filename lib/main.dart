import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vpxfjnmuwpavqrhjyaby.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZweGZqbm11d3BhdnFyaGp5YWJ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk3OTg1ODMsImV4cCI6MjA4NTM3NDU4M30.KWJEfqnRavFCMpLuRvvOh_S2Peo0AcIM4sHMU8rS1Ec',
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
      home: const AuthGate(),
    );
  }
}
