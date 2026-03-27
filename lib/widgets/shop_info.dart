import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopInfo extends StatefulWidget {
  final String shopId; // ID du shop dans Supabase

  const ShopInfo({super.key, required this.shopId});

  @override
  State<ShopInfo> createState() => _ShopInfoState();
}

class _ShopInfoState extends State<ShopInfo> {
  Map<String, dynamic>? shop;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchShop();
  }

  Future<void> fetchShop() async {
    final supabase = Supabase.instance.client;
    try {
      final data = await supabase
          .from('shops')
          .select('*')
          .eq('id', widget.shopId)
          .maybeSingle(); // récupère un seul résultat

      setState(() {
        shop = data;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur fetchShop: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (shop == null) {
      return const SizedBox(
        height: 250,
        child: Center(child: Text('Boutique introuvable')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== HEADER (BANNIERE + AVATAR) =====
        Stack(
          clipBehavior: Clip.none,
          children: [
            // BANNIERE
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(shop!['cover_image'] ??
                      'https://picsum.photos/800/300'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // AVATAR
            Positioned(
              bottom: -40,
              left: 20,
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 42,
                  backgroundImage: NetworkImage(shop!['avatar'] ??
                      'https://picsum.photos/100/100'),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 50),

        // ===== INFOS =====
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NOM
              Text(
                shop!['name'] ?? 'Nom indisponible',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // LOCALISATION
              if (shop!['location'] != null)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18),
                    const SizedBox(width: 5),
                    Text(shop!['location']),
                  ],
                ),

              const SizedBox(height: 6),

              // TELEPHONE
              if (shop!['phone'] != null)
                Row(
                  children: [
                    const Icon(Icons.phone, size: 18),
                    const SizedBox(width: 5),
                    Text(shop!['phone']),
                  ],
                ),

              const SizedBox(height: 6),

              // EMAIL
              if (shop!['email'] != null)
                Row(
                  children: [
                    const Icon(Icons.email, size: 18),
                    const SizedBox(width: 5),
                    Text(shop!['email']),
                  ],
                ),

              const SizedBox(height: 10),

              // RESEAUX SOCIAUX
              Row(
                children: [
                  if (shop!['facebook'] != null)
                    IconButton(
                      icon: const Icon(Icons.facebook),
                      onPressed: () {},
                    ),
                  if (shop!['instagram'] != null)
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () {},
                    ),
                  if (shop!['website'] != null)
                    IconButton(
                      icon: const Icon(Icons.language),
                      onPressed: () {},
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}