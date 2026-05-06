import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../pages/login_page.dart';
import '../pages/home_page.dart';
import '../pages/seller_dashboard_page.dart';
import '../pages/admin_dashboard_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Map<String, dynamic>?> _getUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await Supabase.instance.client
          .from('users') // ⚠️ assure-toi que c'est la bonne table
          .select()
          .eq('id', user.id)
          .maybeSingle();

      return data;
    } catch (e) {
      debugPrint("ERROR loading profile: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    // ❌ Pas connecté
    if (session == null) {
      return const LoginPage();
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserProfile(),
      builder: (context, snapshot) {

        // ⏳ Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ Pas de profil
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginPage(); // ou page création profil
        }

        final profile = snapshot.data!;

        // ✅ Nouvelle logique
        final isAdmin = profile['is_admin'] == true;
        final isSeller = profile['is_seller'] == true;

        // 🔥 Redirection propre
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isAdmin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminDashboardPage(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const HomePage(),
              ),
            );
          }
        });

        // écran temporaire pendant redirect
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}