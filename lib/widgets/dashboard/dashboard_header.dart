import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String username;

  const DashboardHeader({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      color: Colors.blue.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bienvenue $username",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text("Gérez votre boutique facilement"),
        ],
      ),
    );
  }
}