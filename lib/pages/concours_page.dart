import 'package:flutter/material.dart';
import '../../widgets/navbar.dart'; // adapte selon ton chemin
import '../../widgets/concours/concours_list.dart'; // adapte selon ton chemin

class ConcoursPage extends StatelessWidget {
  const ConcoursPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 246, 250),

      body: Column(
        children: [
          // 🔥 HEADER (NavBar)
          NavBar(),

          // 🔥 CONTENT
          const Expanded(
            child: ConcoursList(),
          ),
        ],
      ),
    );
  }
}