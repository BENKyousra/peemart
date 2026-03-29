import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/product_section.dart';
import '../widgets/navbar.dart' hide Widget;
import 'products_list_page.dart';
import 'add_product_page.dart';

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
  bool isSeller = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    loadUserRole(); // ✅ important
  }

  // ===== LOAD USER ROLE =====
  Future<void> loadUserRole() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      final userData = await supabase
          .from('users')
          .select('is_seller')
          .eq('id', user.id)
          .single();

      setState(() {
        isSeller = userData['is_seller'] == true;
      });
    } catch (e) {
      print("Erreur loadUserRole: $e");
    }
  }

  // ===== LOAD PRODUCTS =====
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
        recentProducts = List<Map<String, dynamic>>.from(recent);
        popularProducts = List<Map<String, dynamic>>.from(popular);
        sponsoredProducts = List<Map<String, dynamic>>.from(sponsored);
        isLoading = false;
      });
    } catch (e) {
      print("Erreur fetchProducts: $e");
    }
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          const NavBar(),

          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchProducts,

              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          children: [
                            _buildSection(
                              context,
                              title: 'Nouveautés',
                              icon: Icons.new_releases,
                              products: recentProducts,
                            ),

                            _buildSection(
                              context,
                              title: 'Sponsorisé',
                              icon: Icons.star,
                              products: sponsoredProducts,
                            ),

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

      // ===== FLOATING BUTTON =====
      floatingActionButton: isSeller
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddProductPage(),
                  ),
                );
              },
              backgroundColor: const Color.fromARGB(255, 0, 2, 105),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
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
            MaterialPageRoute(
              builder: (_) => ProductsListPage(title: title),
            ),
          );
        },
      ),
    );
  }
}