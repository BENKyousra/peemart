import 'package:flutter/material.dart';
import '../../pages/concours/participate_page.dart';

class ConcoursCard extends StatelessWidget {
  final String id;
  final String shopName;
  final String avatarUrl;
  final String imageUrl;
  final String description;
  final String type;

  const ConcoursCard({
    super.key,
    required this.id,
    required this.shopName,
    required this.avatarUrl,
    required this.imageUrl,
    required this.description,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(avatarUrl),
                  radius: 22,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shopName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        type.toUpperCase(),
                        style: TextStyle(
                          color: type == "raffle" ? Colors.orange : Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.emoji_events, color: Colors.amber),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ParticipatePage(concoursId: id, type: type),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 10),

          // DESCRIPTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(description, style: const TextStyle(fontSize: 14)),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
