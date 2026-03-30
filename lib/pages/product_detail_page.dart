import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'shop_page.dart';
import '../widgets/comment.dart';
import '../services/comment_service.dart';
import '../models/comment_model.dart';
import '../services/cart_service.dart';

class ProductDetailPage extends StatefulWidget {
  final String title;
  final String imageUrl;
  final List<String> images;
  final double price;
  final String shopName;
  final String shopId;
  final String shopAvatar;
  final double rating;
  final String description;
  final String productId;

  const ProductDetailPage({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.images,
    required this.price,
    required this.shopName,
    required this.shopId,
    required this.shopAvatar,
    required this.rating,
    required this.description,
    required this.productId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int selectedImage = 0;
  late List<String> allImages;
  final CommentService commentService = CommentService();
  final currentUser = Supabase.instance.client.auth.currentUser;
  final CartService cartService = CartService();
  List<CommentModel> comments = [];
  bool isLoadingComments = true;

  @override
  void initState() {
    super.initState();

    allImages = [];

    // ✅ image principale en premier
    if (widget.imageUrl.isNotEmpty) {
      allImages.add(widget.imageUrl);
    }

    // ✅ images galerie ensuite
    if (widget.images.isNotEmpty) {
      allImages.addAll(widget.images);
    }

    selectedImage = 0;

    fetchComments();
  }

  Future<void> fetchComments() async {
    setState(() => isLoadingComments = true);
    comments = await CommentService.fetchComments(widget.productId);
    setState(() => isLoadingComments = false);
  }

  Future<void> handleAddComment(String text, int rating) async {
    try {
      if (text.isEmpty || rating == 0) return;

      await CommentService().addComment(
        productId: widget.productId,
        text: text,
        rating: rating,
      );

      await fetchComments();
    } catch (e) {
      print("❌ ERREUR COMMENT: $e");
    }
  }

  void _openImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              // IMAGE ZOOMABLE
              InteractiveViewer(
                child: Center(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain, // garde dimension
                  ),
                ),
              ),

              // BOUTON FERMER
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
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
              'Détails du produit',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== LES 2 COLONNES =====
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== COLONNE GAUCHE (IMAGES) =====
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Container(
                          height: 350,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _openImage(context, allImages[selectedImage]);
                            },
                            child: Image.network(
                              allImages[selectedImage],
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: allImages.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedImage = index;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          selectedImage == index
                                              ? const Color.fromARGB(
                                                255,
                                                0,
                                                169,
                                                191,
                                              )
                                              : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Image.network(
                                    allImages[index],
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 30),

                  // ===== COLONNE DROITE (DETAILS) =====
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "${widget.price.toStringAsFixed(0)} DA",
                          style: const TextStyle(
                            fontSize: 26,
                            color: Color.fromARGB(255, 0, 169, 191),
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            _buildStars(widget.rating),
                            const SizedBox(width: 6),
                            Text(widget.rating.toStringAsFixed(1)),
                            const SizedBox(width: 4),
                            Text(
                              "(${comments.length})",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ShopPage(shopId: widget.shopId),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  widget.shopAvatar.isNotEmpty
                                      ? widget.shopAvatar
                                      : 'https://picsum.photos/100',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                widget.shopName.isNotEmpty
                                    ? widget.shopName
                                    : "Boutique",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          widget.description,
                          style: const TextStyle(fontSize: 15),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                await cartService.addToCart(widget.productId);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Produit ajouté au panier 🛒",
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text("Ajouté au panier 🛒"),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(18),
                              backgroundColor: const Color.fromARGB(
                                255,
                                0,
                                169,
                                191,
                              ),
                            ),
                            child: const Text(
                              "Ajouter au panier",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ===== COMMENTAIRES =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Commentaires",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
              isLoadingComments
                  ? const CircularProgressIndicator()
                  : Column(
                    children:
                        comments.map((c) {
                          return CommentWidget(
                            id: c.id,
                            name: c.name,
                            rating: c.rating,
                            date: "${c.createdAt.toLocal()}".split(' ')[0],
                            comment: c.content,

                            // 🔥 vérifier propriétaire
                            isOwner: currentUser?.id == c.userId,

                            onDelete: () async {
                              await commentService.deleteComment(
                                c.id,
                                widget.productId,
                              );
                              fetchComments();
                            },

                            onEdit: () {
                              showCommentDialog(
                                context,
                                onSend: (text, rating) async {
                                  await commentService.updateComment(
                                    commentId: c.id,
                                    text: text,
                                    rating: rating,
                                    productId: widget.productId,
                                  );
                                  fetchComments();
                                },
                              );
                            },
                          );
                        }).toList(),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber);
        } else if (index < rating) {
          return const Icon(Icons.star_half, color: Colors.amber);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber);
        }
      }),
    );
  }
}
