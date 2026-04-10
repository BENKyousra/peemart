import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';
import '../pages/seller_dashboard_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Map<String, dynamic>?> _getUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final data = await Supabase.instance.client
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      return const LoginPage();
    }

    return FutureBuilder(
      future: _getUserProfile(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = snapshot.data!;

        // 🔥 CHECK SELLER
        if (profile['is_seller'] == true) {
          return SellerDashboardPage(profile: profile);
        }

        return const HomePage();
      },
    );
  }
}