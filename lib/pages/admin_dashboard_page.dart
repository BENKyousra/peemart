import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/admin_service.dart';
import '../widgets/admin/stat_card.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminService service = AdminService();

  Map<String, dynamic>? stats;
  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final user = Supabase.instance.client.auth.currentUser;

    final s = await service.getStats();
    final p = await service.getProfile(user!.id);

    setState(() {
      stats = s;
      profile = p;
    });
  }

  Future<void> logout() async {
    await service.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (stats == null || profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 0, 1, 59),
        
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            color: Colors.white,
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔵 PROFILE
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: profile!['avatar_url'] != null
                      ? NetworkImage(profile!['avatar_url'])
                      : null,
                  child: profile!['avatar_url'] == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile!['username'] ?? 'Admin',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text("Administrator"),
                  ],
                )
              ],
            ),

            const SizedBox(height: 20),

            // 🔵 STATS
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [

                  StatCard(
                    title: "Users",
                    value: "${stats!['users']}",
                    icon: Icons.people,
                    color: Colors.blue,
                     backgroundImage:
      "https://images.unsplash.com/photo-1522071820081-009f0129c71c",
                  ),

                  StatCard(
                    title: "Products",
                    value: "${stats!['products']}",
                    icon: Icons.shopping_bag,
                    color: Colors.green,
                      backgroundImage:
      "https://images.unsplash.com/photo-1523275335684-37898b6baf30",
                  ),

                  StatCard(
                    title: "Orders",
                    value: "${stats!['orders']}",
                    icon: Icons.shopping_cart,
                    color: Colors.orange,
                     backgroundImage:
      "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d",
                  ),

                  StatCard(
                    title: "Revenue",
                    value: "${stats!['revenue'].toStringAsFixed(0)} DA",
                    icon: Icons.attach_money,
                    color: Colors.purple,
                    backgroundImage: "https://images.unsplash.com/photo-1521737604893-d14cc237f11d",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}