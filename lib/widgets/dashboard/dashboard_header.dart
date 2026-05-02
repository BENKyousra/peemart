import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String shopName;
  final String? coverUrl;
  final String? avatarUrl;

  final VoidCallback onEditAvatar;
  final VoidCallback onEditCover;
  final VoidCallback onEditName;

  const DashboardHeader({
    super.key,
    required this.shopName,
    this.coverUrl,
    this.avatarUrl,
    required this.onEditAvatar,
    required this.onEditCover,
    required this.onEditName,
  });

  bool _isValid(String? url) {
    return url != null && url.isNotEmpty && url.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),

        // =========================
        // COVER SAFE
        // =========================
        image:
            _isValid(coverUrl)
                ? DecorationImage(
                  image: NetworkImage(coverUrl!),
                  fit: BoxFit.cover,
                )
                : null,

        color: Colors.black,
      ),
      child: Stack(
        children: [
          // overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.black.withOpacity(0.35),
            ),
          ),

          // edit cover
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onEditCover,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 18),
              ),
            ),
          ),

          // content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,

                      backgroundImage:
                          _isValid(avatarUrl) ? NetworkImage(avatarUrl!) : null,

                      child:
                          !_isValid(avatarUrl)
                              ? const Icon(Icons.store, size: 30)
                              : null,
                    ),

                    // edit avatar
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: onEditAvatar,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                // text
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Flexible(
      child: Text(
        "Bienvenue $shopName 👋",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ),

    const SizedBox(width: 6),

    GestureDetector(
      onTap: onEditName,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.edit,
          size: 15,
          color: Colors.white,
        ),
      ),
    ),
  ],
),
                      const SizedBox(height: 4),
                      Text(
                        "Gérez votre boutique facilement",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.85),
                        ),
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
