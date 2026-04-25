import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/product_model.dart';
import '../../widgets/product/product_card.dart';
import '../../pages/products/product_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final supabase = Supabase.instance.client;

  List<ProductModel> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  // =========================
  // 🔥 LOAD FAVORITES
  // =========================
  Future<void> loadFavorites() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      // 1. GET FAVORITES IDS
      final favs = await supabase
          .from('favorites')
          .select('product_id')
          .eq('user_id', user.id);

      final ids = List<String>.from(
        favs.map((e) => e['product_id'].toString()),
      );

      if (ids.isEmpty) {
        setState(() {
          products = [];
          isLoading = false;
        });
        return;
      }

      // 2. GET PRODUCTS + SHOP JOIN 🔥 IMPORTANT
      final res = await supabase
          .from('products')
          .select('*, shops(*)')
          .in_('id', ids);

      setState(() {
        products =
            (res as List)
                .map((e) => ProductModel.fromMap(e))
                .toList();

        isLoading = false;
      });
    } catch (e) {
      print("FAVORITES ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  // =========================
  // 🔄 REFRESH
  // =========================
  Future<void> refresh() async {
    setState(() => isLoading = true);
    await loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 0, 1, 59),
                Color.fromARGB(255, 0, 2, 105),
              ],
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Mes Favoris',
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),

      // =========================
      // BODY
      // =========================
      body: products.isEmpty
          ? const Center(
              child: Text(
                "Aucun produit en favori",
                style: TextStyle(fontSize: 16),
              ),
            )
          : RefreshIndicator(
              onRefresh: refresh,
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(
                            product: product,
                          ),
                        ),
                      );
                    },
                    child: ProductCard(
                      product: product,
                      reviewCount: product.reviewCount,
                    ),
                  );
                },
              ),
            ),
    );
  }
}