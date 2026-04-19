import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String username;
  final String? coverUrl;
  final String? avatarUrl;

  const DashboardHeader({
    super.key,
    required this.username,
    this.coverUrl,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: coverUrl != null
            ? DecorationImage(
                image: NetworkImage(coverUrl!),
                fit: BoxFit.cover,
              )
            : null,
        color: Colors.black, // fallback si pas d'image
      ),
      child: Stack(
        children: [
          // 🔥 DARK OVERLAY (lisibilité)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
            ),
          ),

          // 📦 CONTENT
          Padding(
            padding: const EdgeInsets.all(30),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 👤 AVATAR SHOP
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl!)
                      : null,
                  child: avatarUrl == null
                      ? const Icon(Icons.store, size: 30)
                      : null,
                ),

                const SizedBox(width: 12),

                // TEXT
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // children: [
                    //   Text(
                    //     "Bienvenue $username 👋",
                    //     style: const TextStyle(
                    //       fontSize: 18,
                    //       fontWeight: FontWeight.bold,
                    //       color: Colors.white,
                    //     ),
                    //   ),
                    //   const SizedBox(height: 4),
                    //   Text(
                    //     "Gérez votre boutique facilement",
                    //     style: TextStyle(
                    //       fontSize: 13,
                    //       color: Colors.white.withOpacity(0.8),
                    //     ),
                    //   ),
                    // ],
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