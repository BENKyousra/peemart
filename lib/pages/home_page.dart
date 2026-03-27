import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/product_section.dart';
import '../widgets/navbar.dart';
import 'products_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> recentProducts = [];
  List<Map<String, dynamic>> popularProducts = [];
  List<Map<String, dynamic>> sponsoredProducts = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final supabase = Supabase.instance.client;

    try {
      final recent = await supabase
          .from('products')
          .select('*, shops(*), product_images(*)')
          .order('created_at', ascending: false)
          .limit(10);

      final popular = await supabase
          .from('products')
          .select('*, shops(*), product_images(*)')
          .order('rating', ascending: false)
          .limit(10);

      final sponsored = await supabase
          .from('products')
          .select('*, shops(*), product_images(*)')
          .limit(10);

      setState(() {
        recentProducts = List<Map<String, dynamic>>.from(
          recent as List<dynamic>,
        );
        popularProducts = List<Map<String, dynamic>>.from(
          popular as List<dynamic>,
        );
        sponsoredProducts = List<Map<String, dynamic>>.from(
          sponsored as List<dynamic>,
        );
        isLoading = false;
      });
    } catch (e) {
      print("Erreur: $e");
    }
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
              onRefresh: fetchProducts,

              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            children: [
                              // ===== NOUVEAUTÉS =====
                              _buildSection(
                                context,
                                title: 'Nouveautés',
                                icon: Icons.new_releases,
                                products: recentProducts,
                              ),

                              // ===== SPONSORISÉ =====
                              _buildSection(
                                context,
                                title: 'Sponsorisé',
                                icon: Icons.star,
                                products: sponsoredProducts,
                              ),

                              // ===== POPULAIRES =====
                              _buildSection(
                                context,
                                title: 'Les plus populaires',
                                icon: Icons.whatshot,
                                products: popularProducts,
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

  // ===== SECTION BUILDER =====
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> products,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        icon: icon,
        title: title,
        products: products,
        onSeeMore: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductsListPage(title: title)),
          );
        },
      ),
    );
  }
}
