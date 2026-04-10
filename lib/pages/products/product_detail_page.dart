import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/product_model.dart';
import '../../widgets/product/comment_section.dart';
import '../../widgets/product/comment.dart';
import '../../widgets/product/product_images.dart';
import '../../widgets/product/product_info.dart';
import '../../services/comment_service.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final CommentService commentService = CommentService();

  List<Map<String, dynamic>> variants = [];
  bool isLoadingVariants = true;

  @override
  void initState() {
    super.initState();
    loadVariants();
  }

  // 🔥 LOAD VARIANTS FROM DB
  Future<void> loadVariants() async {
    final supabase = Supabase.instance.client;

    try {
      final res = await supabase
          .from('product_variants')
          .select()
          .eq('product_id', widget.product.id);

      setState(() {
        variants = List<Map<String, dynamic>>.from(res);
        isLoadingVariants = false;
      });
    } catch (e) {
      print("Erreur variants: $e");
      setState(() => isLoadingVariants = false);
    }
  }

  // 🔥 ADD COMMENT
  Future<void> handleAddComment(String text, int rating) async {
    await commentService.addComment(
      productId: widget.product.id,
      text: text,
      rating: rating,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 LOADING
    if (isLoadingVariants) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    print("DEBUG VARIANTS: $variants");
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
              widget.product.title,
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== PRODUCT SECTION =====
                isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // IMAGES
                          Expanded(
                            flex: 1,
                            child: ProductImages(
                              mainImage: widget.product.image,
                              images: widget.product.images,
                            ),
                          ),

                          const SizedBox(width: 20),

                          // INFO
                          Expanded(
                            flex: 1,
                            child: ProductInfo(
                              product: widget.product,
                              commentsCount: 0,
                              shopId: widget.product.shopId,
                              shopName: widget.product.shopName,
                              shopAvatar: widget.product.shopAvatar,
                              variants: variants, // 🔥 IMPORTANT
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          ProductImages(
                            mainImage: widget.product.image,
                            images: widget.product.images,
                          ),
                          const SizedBox(height: 20),
                          ProductInfo(
                            product: widget.product,
                            commentsCount: 0,
                            shopId: widget.product.shopId,
                            shopName: widget.product.shopName,
                            shopAvatar: widget.product.shopAvatar,
                            variants: variants, // 🔥 IMPORTANT
                          ),
                        ],
                      ),

                const SizedBox(height: 30),

                // ===== COMMENTS HEADER =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Commentaires",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CommentButton(
                      onPressed: () {
                        showCommentDialog(
                          context,
                          onSend: (text, rating) {
                            handleAddComment(text, rating);
                          },
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ===== COMMENTS LIST =====
                CommentSection(productId: widget.product.id),
              ],
            ),
          );
        },
      ),
    );
  }
}