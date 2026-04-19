import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/navbar.dart';
import 'influencer_page.dart';

class InfluencersListPage extends StatefulWidget {
  const InfluencersListPage({super.key});

  @override
  State<InfluencersListPage> createState() => _InfluencersListPageState();
}

class _InfluencersListPageState extends State<InfluencersListPage> {
  List<Map<String, dynamic>> influencers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadInfluencers();
  }

  Future<void> loadInfluencers() async {
    try {
      final data = await Supabase.instance.client
          .from('influencers')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        influencers = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      print("🔥 ERROR loadInfluencers: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const NavBar(),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : influencers.isEmpty
                    ? const Center(child: Text("Aucun influenceur"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: influencers.length,
                        itemBuilder: (context, index) {
                          final inf = influencers[index];

                          final avatar = inf['avatar'];
                          final name = inf['name'] ?? '';
                          final code = inf['discount_code'] ?? '';

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: (avatar != null && avatar != '')
                                    ? NetworkImage(avatar)
                                    : null,
                                child: (avatar == null || avatar == '')
                                    ? const Icon(Icons.person)
                                    : null,
                              ),

                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              subtitle: Text("Code: $code"),

                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InfluencerPage(
                                      influencerId: inf['id'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}