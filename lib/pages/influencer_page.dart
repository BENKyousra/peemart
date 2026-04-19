import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/post_service.dart';
import '../widgets/navbar.dart';
import '../widgets/product/product_card.dart';
import '../widgets/influencer/influencer_info.dart';
import '../../models/product_model.dart';

class InfluencerPage extends StatefulWidget {
  final String influencerId;

  const InfluencerPage({super.key, required this.influencerId});

  @override
  State<InfluencerPage> createState() => _InfluencerPageState();
}

class _InfluencerPageState extends State<InfluencerPage> {
  final PostService _postService = PostService();

  List<ProductModel> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

 Future<void> fetchProducts() async {
  try {
    final supabase = Supabase.instance.client;

    final posts = await supabase
        .from('posts')
        .select('*, products(*, product_images(*), shops(*)), influencers(*)')
        .eq('influencer_id', widget.influencerId);

    print("🔥 POSTS RAW: $posts");

    final list = List<Map<String, dynamic>>.from(posts);

    final mappedProducts = <ProductModel>[];

    for (final post in list) {
      final product = post['products'];

      if (product == null) continue;

      try {
        mappedProducts.add(ProductModel.fromMap(product));
      } catch (e) {
        print("❌ mapping error: $e");
      }
    }

    setState(() {
      products = mappedProducts;
      isLoading = false;
    });
  } catch (e, stack) {
    print("🔥 ERROR: $e");
    print(stack);

    setState(() => isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const NavBar(),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? const Center(child: Text("Aucun produit"))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InfluencerInfo(
                                influencerId: widget.influencerId),

                            const SizedBox(height: 20),

                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                "Produits",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                itemCount: products.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      MediaQuery.of(context).size.width > 1200
                                          ? 5
                                          : 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.65,
                                ),
                                itemBuilder: (context, index) {
                                  final product = products[index];

                                  return ProductCard(
                                    product: product,
                                    reviewCount: product.reviewCount ?? 0,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}