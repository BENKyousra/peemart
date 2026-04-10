import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/product/product_section.dart';
import '../widgets/navbar.dart';
import 'products/products_list_page.dart';
import '../models/product_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ProductModel> recentProducts = [];
  List<ProductModel> popularProducts = [];
  List<ProductModel> sponsoredProducts = [];

  bool isLoading = true;
  bool isSeller = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ===== LOAD ALL DATA =====
  Future<void> loadData() async {
    await Future.wait([
      fetchProducts(),
      loadUserRole(),
    ]);
  }

  // ===== USER ROLE =====
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

  // ===== PRODUCTS =====
  Future<void> fetchProducts() async {
    final supabase = Supabase.instance.client;

    try {
      final results = await Future.wait([
        supabase
            .from('products')
            .select('*, shops(*), product_images(*)')
            .order('created_at', ascending: false)
            .limit(10),

        supabase
            .from('products')
            .select('*, shops(*), product_images(*)')
            .order('rating', ascending: false)
            .limit(10),

        supabase
            .from('products')
            .select('*, shops(*), product_images(*)')
            .limit(10),
      ]);

      final recent = results[0] as List;
      final popular = results[1] as List;
      final sponsored = results[2] as List;

      setState(() {
        recentProducts =
            recent.map((p) => ProductModel.fromMap(p)).toList();

        popularProducts =
            popular.map((p) => ProductModel.fromMap(p)).toList();

        sponsoredProducts =
            sponsored.map((p) => ProductModel.fromMap(p)).toList();

        isLoading = false;
      });
    } catch (e) {
      print("Erreur fetchProducts: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          const NavBar(),

          Expanded(
            child: RefreshIndicator(
              onRefresh: loadData, // 🔥 refresh global

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
    );
  }

  // ===== SECTION BUILDER =====
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<ProductModel> products,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // 🔥 plus léger
            blurRadius: 6,
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
              builder: (_) => ProductsListPage(
                title: title,
              ),
            ),
          );
        },
      ),
    );
  }
}