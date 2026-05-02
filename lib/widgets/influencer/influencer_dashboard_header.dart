// widgets/influencer/dashboard/influencer_dashboard_header.dart

import 'package:flutter/material.dart';

class InfluencerDashboardHeader extends StatelessWidget {
  final Map<String, dynamic>? influencer;

  const InfluencerDashboardHeader({super.key, required this.influencer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 0, 1, 59),
            Color.fromARGB(255, 0, 2, 105),
          ],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: influencer?['avatar'] != null
                ? NetworkImage(influencer!['avatar'])
                : null,
            child: influencer?['avatar'] == null
                ? const Icon(Icons.person, size: 35, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      influencer?['name'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (influencer?['is_verified'] == true)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(Icons.verified, color: Colors.blue, size: 18),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.discount_outlined, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        influencer?['discount_code'] ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}