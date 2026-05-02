import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../pages/products/edit_product_page.dart';

class ProductsSection extends StatefulWidget {
  const ProductsSection({super.key});

  @override
  State<ProductsSection> createState() => _ProductsSectionState();
}

class _ProductsSectionState extends State<ProductsSection> {
  final ProductService service = ProductService();

  List products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final shopId = await service.getUserShopId();

    final data = await service.supabase
        .from('products')
        .select('*, product_images(*)')
        .eq('shop_id', shopId)
        .order('created_at', ascending: false);

    setState(() {
      products = data;
      isLoading = false;
    });
  }

  Future<void> deleteProduct(String id) async {
    await service.supabase.from('products').delete().eq('id', id);
    loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return const Center(child: Text("Aucun produit"));
    }

    return ListView.builder(
       shrinkWrap: true, // ✅ IMPORTANT
  physics: const NeverScrollableScrollPhysics(), // ✅ IMPORTANT
      itemCount: products.length,
      itemBuilder: (context, i) {
        final p = products[i];

        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            leading:
                p['image'] != null
                    ? Image.network(p['image'], width: 50, fit: BoxFit.cover)
                    : const Icon(Icons.image),

            title: Text(p['title'] ?? ''),
            subtitle: Text("${p['price']} DA"),

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✏️ EDIT (future)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProductPage(product: p),
                      ),
                    );

                    if (result == true) {
                      loadProducts(); // refresh
                    }
                  },
                ),

                // 🗑️ DELETE
                IconButton(
                  icon: const Icon(Icons.delete, color: Color.fromARGB(255, 255, 10, 88)),
                  onPressed: () async {
                    final confirm = await showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: const Text("Supprimer ?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Non"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Oui"),
                              ),
                            ],
                          ),
                    );

                    if (confirm == true) {
                      await service.deleteProduct(p['id']);
                      loadProducts();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
