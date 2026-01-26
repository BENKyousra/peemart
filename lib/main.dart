import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'widgets/navbar.dart';
import 'pages/login_page.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );

  runApp(const PeeMartApp());
}

class PeeMartApp extends StatelessWidget {
  const PeeMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeeMart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Swansea'),

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // ⏳ Chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // ❌ PAS CONNECTÉ → LOGIN
          if (!snapshot.hasData) {
            return const LoginPage();
          }

          // ✅ CONNECTÉ → HOME AVEC NAVBAR
          final user = snapshot.data!;

          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  NavBar(
                    isConnected: true,
                    username: user.email!.split('@')[0], // ex: test
                    avatarUrl:
                        'https://i.pravatar.cc/150?u=${user.uid}', // avatar auto
                    notificationsCount: 3,
                    favoritesCount: 5,
                    cartCount: 2,
                    onSearch: (query) {
                      print('Recherche : $query');
                    },
                  ),

                  const SizedBox(height: 50),
                  const Center(
                    child: Text(
                      'Contenu du site PeeMart ici',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
