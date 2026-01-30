import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/product_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // ===== FAKE DATA (plus tard Supabase) =====
  static final List<Map<String, dynamic>> recentProducts = [
    {
      'title': 'Chaussures Nike Air',
      'image_url':
          'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg',
      'price': 8500.0,
      'rating': 4.5,
      'shop_name': 'Nike',
      'shop_avatar':
          'https://images.pexels.com/photos/11297751/pexels-photo-11297751.jpeg?_gl=1*1pdqyqd*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk2MTU3NDkkbzU5JGcxJHQxNzY5NjE1ODc1JGoyMCRsMCRoMA..',
    },
    {
      'title': 'Parfum Luxueux',
      'image_url':
          'https://images.pexels.com/photos/15271715/pexels-photo-15271715.jpeg?_gl=1*1bjmyyf*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk1NTI0MzMkbzU1JGcxJHQxNzY5NTUyNzM3JGoyOSRsMCRoMA..',
      'price': 12000.0,
      'rating': 4.8,
      'shop_name': 'DZ Luxury',
      'shop_avatar':
          'https://images.pexels.com/photos/8516167/pexels-photo-8516167.jpeg?_gl=1*m7u12w*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk2MTU3NDkkbzU5JGcxJHQxNzY5NjE2MjQwJGoyJGwwJGgw',
    },
    {
      'title': 'Montre Classique',
      'image_url':
          'https://images.pexels.com/photos/190819/pexels-photo-190819.jpeg',
      'price': 8500.0,
      'rating': 4.6,
      'shop_name': 'Time Store',
      'shop_avatar':
          'https://images.pexels.com/photos/33750543/pexels-photo-33750543.jpeg?_gl=1*1marlnf*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk2MTU3NDkkbzU5JGcxJHQxNzY5NjE2Mzc1JGo0MiRsMCRoMA..',
    },
    {
      'title': 'Parfum Luxueux',
      'image_url':
          'https://images.pexels.com/photos/31117962/pexels-photo-31117962.jpeg?_gl=1*j5mfsd*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk2MTU3NDkkbzU5JGcxJHQxNzY5NjE2MDA1JGo0NiRsMCRoMA..',
      'price': 12000.0,
      'rating': 4.8,
      'shop_name': 'DZ Luxury',
      'shop_avatar':
          'https://images.pexels.com/photos/8516167/pexels-photo-8516167.jpeg?_gl=1*m7u12w*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk2MTU3NDkkbzU5JGcxJHQxNzY5NjE2MjQwJGoyJGwwJGgw',
    },
    {
      'title': 'Montre Classique',
      'image_url':
          'https://images.pexels.com/photos/190819/pexels-photo-190819.jpeg',
      'price': 8500.0,
      'rating': 4.6,
      'shop_name': 'Time Store',
      'shop_avatar':
          'https://images.pexels.com/photos/33750543/pexels-photo-33750543.jpeg?_gl=1*1marlnf*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk2MTU3NDkkbzU5JGcxJHQxNzY5NjE2Mzc1JGo0MiRsMCRoMA..',
    },
    {
      'title': 'Parfum Luxueux',
      'image_url':
          'https://images.pexels.com/photos/31117962/pexels-photo-31117962.jpeg?_gl=1*j5mfsd*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk2MTU3NDkkbzU5JGcxJHQxNzY5NjE2MDA1JGo0NiRsMCRoMA..',
      'price': 12000.0,
      'rating': 4.8,
      'shop_name': 'DZ Luxury',
      'shop_avatar':
          'https://images.pexels.com/photos/8516167/pexels-photo-8516167.jpeg?_gl=1*m7u12w*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk2MTU3NDkkbzU5JGcxJHQxNzY5NjE2MjQwJGoyJGwwJGgw',
    },
  ];

  static final List<Map<String, dynamic>> sponsoredProducts = [
    {
      'title': 'Chaussures Nike Air',
      'image_url':
          'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg',
      'price': 8500.0,
      'rating': 4.5,
      'shop_name': 'Nike',
      'shop_avatar':
          'https://images.pexels.com/photos/11297751/pexels-photo-11297751.jpeg?_gl=1*1pdqyqd*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk2MTU3NDkkbzU5JGcxJHQxNzY5NjE1ODc1JGoyMCRsMCRoMA..',
    },
    {
      'title': 'Montre Classique',
      'image_url':
          'https://images.pexels.com/photos/190819/pexels-photo-190819.jpeg',
      'price': 8500.0,
      'rating': 4.6,
      'shop_name': 'Time Store',
      'shop_avatar':
          'https://images.pexels.com/photos/33750543/pexels-photo-33750543.jpeg?_gl=1*1marlnf*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk2MTU3NDkkbzU5JGcxJHQxNzY5NjE2Mzc1JGo0MiRsMCRoMA..',
    },
    {
      'title': 'Parfum Luxueux',
      'image_url':
          'https://images.pexels.com/photos/31117962/pexels-photo-31117962.jpeg?_gl=1*j5mfsd*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk2MTU3NDkkbzU5JGcxJHQxNzY5NjE2MDA1JGo0NiRsMCRoMA..',
      'price': 12000.0,
      'rating': 4.8,
      'shop_name': 'DZ Luxury',
      'shop_avatar':
          'https://images.pexels.com/photos/8516167/pexels-photo-8516167.jpeg?_gl=1*m7u12w*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk2MTU3NDkkbzU5JGcxJHQxNzY5NjE2MjQwJGoyJGwwJGgw',
    },
  ];

  static final List<Map<String, dynamic>> popularProducts = [
    {
      'title': 'Montre Classique',
      'image_url':
          'https://images.pexels.com/photos/190819/pexels-photo-190819.jpeg',
      'price': 8500.0,
      'rating': 4.6,
      'shop_name': 'Time Store',
      'shop_avatar':
          'https://images.pexels.com/photos/33750543/pexels-photo-33750543.jpeg?_gl=1*1marlnf*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk2MTU3NDkkbzU5JGcxJHQxNzY5NjE2Mzc1JGo0MiRsMCRoMA..',
    },
    {
      'title': 'Parfum Luxueux',
      'image_url':
          'https://images.pexels.com/photos/31117962/pexels-photo-31117962.jpeg?_gl=1*j5mfsd*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk2MTU3NDkkbzU5JGcxJHQxNzY5NjE2MDA1JGo0NiRsMCRoMA..',
      'price': 12000.0,
      'rating': 4.8,
      'shop_name': 'DZ Luxury',
      'shop_avatar':
          'https://images.pexels.com/photos/8516167/pexels-photo-8516167.jpeg?_gl=1*m7u12w*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk2MTU3NDkkbzU5JGcxJHQxNzY5NjE2MjQwJGoyJGwwJGgw',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          const NavBar(),
          Expanded(
            child: RefreshIndicator(
              color: Colors.blue, // couleur du cercle
              backgroundColor: Colors.white, // arrière-plan du cercle
              onRefresh: () async {
                // ta fonction qui recharge les produits
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      // ===== Nouveautés =====
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white, // couleur du fond du cadre
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ProductSection(
                          icon: Icons.new_releases,
                          title: 'Nouveautés',
                          products: recentProducts,
                          onSeeMore: () {
                            // Naviguer vers la liste complète
                          },
                        ),
                      ),

                      // ===== Sponsorisé =====
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ProductSection(
                          icon: Icons.star,
                          title: 'Sponsorisé',
                          products: sponsoredProducts,
                          onSeeMore: () {},
                        ),
                      ),

                      // ===== Les plus populaires =====
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ProductSection(
                          icon: Icons.whatshot,
                          title: 'Les plus populaires',
                          products: popularProducts,
                          onSeeMore: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
