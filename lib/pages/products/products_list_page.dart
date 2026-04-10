import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/product/product_card.dart';
import '../../models/product_model.dart';

class ProductsListPage extends StatefulWidget {
  final String title;
  final String? filterColumn;
  final dynamic filterValue;

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
  List<ProductModel> products = []; // 🔥 plus de Map
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final supabase = Supabase.instance.client;

    try {
      var query = supabase
          .from('products')
          .select('*, shops(*), product_images(*)');

      if (widget.filterColumn != null && widget.filterValue != null) {
        query = query.eq(widget.filterColumn!, widget.filterValue);
      }

      final data =
          await query.order('created_at', ascending: false).limit(50);

      // 🔥 CONVERSION PROPRE
      final productsList = (data as List)
          .map((e) => ProductModel.fromMap(e))
          .toList();

      setState(() {
        products = productsList;
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
            title: Text(
              widget.title,
              style: const TextStyle(fontSize: 28, color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return ProductCard(
                  product: product, // 🔥 CLEAN
                  reviewCount: 0, // 👉 adapte si tu l’ajoutes dans le model
                  onRefresh: fetchProducts,
                );
              },
            ),
    );
  }
}