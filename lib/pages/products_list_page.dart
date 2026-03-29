import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/product_card.dart';

class ProductsListPage extends StatefulWidget {
  final String title;
  final String? filterColumn; // ex: 'category', 'shop_id', etc.
  final dynamic filterValue; // valeur du filtre

  const ProductsListPage({
    super.key,
    required this.title,
    this.filterColumn,
    this.filterValue,
  });

  @override
  State<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final supabase = Supabase.instance.client;

    try {
      // Requête Supabase
      var query = supabase
          .from('products')
          .select('*, shops(*), product_images(*)');

      // Appliquer un filtre si nécessaire
      if (widget.filterColumn != null && widget.filterValue != null) {
        query = query.eq(widget.filterColumn!, widget.filterValue);
      }

      final data = await query.order('created_at', ascending: false).limit(50);

      setState(() {
        products = List<Map<String, dynamic>>.from(data);
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
            title: Text(
              widget.title,
              style: const TextStyle(fontSize: 28, color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  // Récupérer la galerie d'images
                  List<String> images = [];
                  if (product['product_images'] != null) {
                    images =
                        (product['product_images'] as List)
                            .map((e) => e['image_url'] as String)
                            .toList();
                  }

                  return ProductCard(
                    productId: product['id'],
                    title: product['title'] ?? '',
                    imageUrl: product['image_url'] ?? '',
                    images: images,
                    price: (product['price'] as num?)?.toDouble() ?? 0.0,
                    shopName: product['shops']?['name'] ?? '',
                    shopAvatar: product['shops']?['avatar'] ?? '',
                    shopId: product['shop_id'],
                    rating: (product['rating'] as num?)?.toDouble() ?? 0,
                    reviewCount: product['review_count'] ?? 0,
                    onRefresh: fetchProducts,
                  );
                },
              ),
    );
  }
}
