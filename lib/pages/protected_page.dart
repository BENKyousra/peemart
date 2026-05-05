import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../pages/login_page.dart';
import '../pages/admin_dashboard_page.dart';

class ProtectedPage extends StatelessWidget {
  final Widget child;

  const ProtectedPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const LoginPage();
    }

    return FutureBuilder(
      future: Supabase.instance.client
          .from('users')
          .select('role')
          .eq('id', user.id)
          .single(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data!['role'];

        // 🔥 ADMIN → bloqué partout sauf dashboard
        if (role == 'admin') {
          return const AdminDashboardPage();
        }

        // 🔥 USER → accès normal
        return child;
      },
    );
  }
}