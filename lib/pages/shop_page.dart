import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/product/product_card.dart';
import '../widgets/shop_info.dart';
import '../models/product_model.dart';

class ShopPage extends StatefulWidget {
  final String shopId;

  const ShopPage({super.key, required this.shopId});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<ProductModel> products = []; // 🔥 plus de Map
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await Supabase.instance.client
          .from('products')
          .select('*, product_images(*), shops(*)')
          .eq('shop_id', widget.shopId);

      // 🔥 CONVERSION PROPRE
      final data = (response as List)
          .map((e) => ProductModel.fromMap(e))
          .toList();

      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur fetchProducts: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 0, 1, 59),
                Color.fromARGB(255, 0, 2, 105),
              ],
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              "Boutique",
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== SHOP INFO =====
            ShopInfo(shopId: widget.shopId),

            const SizedBox(height: 20),

            // ===== TITLE =====
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Produits de la boutique",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // ===== GRID =====
            Padding(
              padding: const EdgeInsets.all(12),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.65,
                      ),
                      itemBuilder: (context, index) {
                        final product = products[index];

                        return ProductCard(
                          product: product, // 🔥 CLEAN
                          reviewCount: 0, // 👉 adapte si dispo
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}