import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/product_card.dart';
import '../widgets/shop_info.dart';

class ShopPage extends StatefulWidget {
  final String shopId; // 🔥 On ne passe plus shopName/shopAvatar
  const ShopPage({super.key, required this.shopId});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<Map<String, dynamic>> products = [];
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
          .select('*, product_images(*), shops(*)') // ✅ AJOUT ICI
          .eq('shop_id', widget.shopId);
      // Conversion sûre en List<Map<String, dynamic>>
      final data =
          (response as List<dynamic>)
              .map((e) => e as Map<String, dynamic>)
              .toList();

      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur fetchProducts: $e');
      setState(() {
        isLoading = false;
      });
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
            ShopInfo(shopId: widget.shopId), // ✅ garder en String

            const SizedBox(height: 20),

            // ===== TITRE PRODUITS =====
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Produits de la boutique",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // ===== GRID PRODUITS =====
            Padding(
              padding: const EdgeInsets.all(12),
              child:
                  isLoading
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

                          // ===== IMAGES =====
                          List<String> images = [];
                          if (product['product_images'] != null) {
                            images =
                                (product['product_images'] as List)
                                    .map((e) => e['image_url'] as String)
                                    .toList();
                          }

                          final imageUrl =
                              images.isNotEmpty
                                  ? images[0]
                                  : 'https://via.placeholder.com/150';

                          // ===== SHOP =====
                          final shop =
                              product['shops'] as Map<String, dynamic>?;

                          return ProductCard(
                            productId: product['id'].toString(),
                            title: product['title'] ?? '',
                            imageUrl: imageUrl,
                            images: images,
                            price:
                                (product['price'] as num?)?.toDouble() ?? 0.0,

                            // 🔥 FIX ICI
                            shopName: shop?['name'] ?? '',
                            shopAvatar: shop?['avatar'] ?? '',

                            shopId: product['shop_id'].toString(),

                            rating:
                                (product['rating'] as num?)?.toDouble() ?? 0,
                            reviewCount: product['review_count'] ?? 0,
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
