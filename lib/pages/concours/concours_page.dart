import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';
import '../../widgets/concours/concours_list.dart';
import '../../pages/concours/create_concours_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConcoursPage extends StatefulWidget {
  const ConcoursPage({super.key});

  @override
  State<ConcoursPage> createState() => _ConcoursPageState();
}

class _ConcoursPageState extends State<ConcoursPage> {
  bool isSeller = false;
  bool loading = true;

  final ScrollController _scrollController = ScrollController();
  double scrollOffset = 0;

  @override
  void initState() {
    super.initState();

    loadUserRole();

    // 🔥 CONNECT SCROLL
    _scrollController.addListener(() {
      setState(() {
        scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadUserRole() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      final data = await supabase
          .from('users')
          .select('is_seller')
          .eq('id', user.id)
          .single();

      setState(() {
        isSeller = data['is_seller'] == true;
        loading = false;
      });
    } catch (e) {
      print("Error load seller: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 246, 250),

      // 🔥 FLOATING BUTTON
      floatingActionButton: loading
          ? null
          : isSeller
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateConcoursPage(),
                      ),
                    );
                  },
                  backgroundColor: const Color.fromARGB(255, 0, 2, 105),
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,

      body: Column(
        children: [
          // 🔥 NAVBAR CONNECTÉ AU SCROLL
          NavBar(scrollOffset: scrollOffset),

          // 📦 LISTE
          Expanded(
            child: ConcoursList(
              scrollController: _scrollController,
            ),
          ),
        ],
      ),
    );
  }
}