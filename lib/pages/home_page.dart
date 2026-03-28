import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/navbar.dart';
import '../widgets/product_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> recentProducts = [];
  List<Map<String, dynamic>> sponsoredProducts = [];
  List<Map<String, dynamic>> popularProducts = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => isLoading = true);

    try {
      // ===== Nouveautés =====
      recentProducts = List<Map<String, dynamic>>.from(
        await supabase
            .from('products')
            .select('''
            id,
            title,
            price,
            image_url,
            category,
            rating,
            created_at,
            shops:products_shop_id_fkey (
              id,
              name,
              avatar_url
            )
          ''')
            .order('created_at', ascending: false)
            .limit(10),
      );

      // ===== Sponsorisé =====
      sponsoredProducts = List<Map<String, dynamic>>.from(
        await supabase
            .from('products')
            .select('''
            id,
            title,
            price,
            image_url,
            category,
            rating,
            is_sponsored,
            shops:products_shop_id_fkey (
              id,
              name,
              avatar_url
            )
          ''')
            .eq('is_sponsored', true)
            .limit(10),
      );

      // ===== Les plus populaires =====
      popularProducts = List<Map<String, dynamic>>.from(
        await supabase
            .from('products')
            .select('''
            id,
            title,
            price,
            image_url,
            category,
            rating,
            shops:products_shop_id_fkey (
              id,
              name,
              avatar_url
            )
          ''')
            .order('rating', ascending: false)
            .limit(10),
      );
    } catch (e) {
      debugPrint('❌ Error loading products: $e');
    }

    setState(() => isLoading = false);
  }

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
              onRefresh: _loadProducts,
              child:
                  isLoading
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                      : SingleChildScrollView(
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
                                  color:
                                      Colors.white, // couleur du fond du cadre
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
