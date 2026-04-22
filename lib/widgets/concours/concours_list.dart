import 'package:flutter/material.dart';

class ConcoursList extends StatelessWidget {
  const ConcoursList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ConcoursCard(
          shopName: "Techo Store",
          avatarUrl: "https://images.pexels.com/photos/11970084/pexels-photo-11970084.jpeg?_gl=1*1o6ms1c*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3NzY3Mjg5NjYkbzY4JGcxJHQxNzc2NzI5MDEyJGoxNCRsMCRoMA..",
          date: "21 Avril 2026",
          imageUrl:
              "https://static.vecteezy.com/system/resources/thumbnails/016/914/525/small_2x/gift-box-with-bonus-money-coins-bills-crown-free-vector.jpg",
          text:
              "🎉 Grand concours ! Gagnez un bon d’achat de 5000 DA en participant maintenant !",
        ),
        SizedBox(height: 16),
        ConcoursCard(
          shopName: "Trend DZ",
          avatarUrl: "https://images.pexels.com/photos/36724751/pexels-photo-36724751.jpeg?_gl=1*ytn0zo*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3NzY3Mjg5NjYkbzY4JGcxJHQxNzc2NzI5MDY2JGo1OSRsMCRoMA..",
          date: "20 Avril 2026",
          imageUrl:
              "https://static.vecteezy.com/system/resources/thumbnails/006/795/141/small_2x/gift-voucher-and-shopping-certificate-banner-template-with-people-characters-getting-sale-bonus-clients-loyalty-program-discount-events-and-special-offer-event-flat-cartoon-illustration-free-vector.jpg",
          text:
              "🔥 Participez et gagnez un outfit complet + livraison gratuite !",
        ),
      ],
    );
  }
}

class ConcoursCard extends StatelessWidget {
  final String shopName;
  final String avatarUrl;
  final String date;
  final String imageUrl;
  final String text;

  const ConcoursCard({
    super.key,
    required this.shopName,
    required this.avatarUrl,
    required this.date,
    required this.imageUrl,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER SHOP
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
                        date,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.emoji_events, color: Colors.amber),
              ],
            ),
          ),
           Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}