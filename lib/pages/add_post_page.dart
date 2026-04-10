import 'package:flutter/material.dart';
import 'package:peemart/services/post_service.dart';
import 'package:peemart/services/product_service.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController descriptionController = TextEditingController();

  final PostService postService = PostService();
  final ProductService productService = ProductService();

  String? influencerId;
  String? selectedProductId;

  List<Map<String, dynamic>> products = [];

  bool isLoading = true;
  bool isUploading = false;

  List<Uint8List> selectedImages = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final influencer = await postService.getMyInfluencer();
    final prods = await productService.getAllProducts();

    setState(() {
      influencerId = influencer?['id'];
      products = prods;
      isLoading = false;
    });
  }

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();

    if (files.isEmpty) return;

    for (var file in files) {
      final bytes = await file.readAsBytes();
      selectedImages.add(bytes);
    }

    setState(() {});
  }

  Future<void> addPost() async {
    if (influencerId == null || selectedProductId == null) return;

    setState(() => isUploading = true);

    List<String> imageUrls = [];

    for (var img in selectedImages) {
      final url = await postService.uploadPostImage(img);
      imageUrls.add(url);
    }

    await postService.addPostWithImages(
      influencerId: influencerId!,
      productId: selectedProductId!,
      description: descriptionController.text,
      imageUrls: imageUrls,
    );

    setState(() => isUploading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "New Post",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔹 CARD
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 description
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Share your experience...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 🔹 product dropdown
                  DropdownButtonFormField<String>(
                    value: selectedProductId,
                    hint: const Text("Select product"),
                    items: products.map((product) {
                      return DropdownMenuItem<String>(
                        value: product['id'],
                        child: Text(product['title']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedProductId = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 🔹 images button
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        onPressed: pickImages,
                        icon: const Icon(Icons.image, color: Colors.white),
                        label: const Text(
                          "Add Images",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        "${selectedImages.length} selected",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// 🔹 preview images
                  if (selectedImages.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(
                                    selectedImages[index],
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              /// ❌ delete button
                              Positioned(
                                right: 4,
                                top: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔹 publish button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                onPressed: isUploading ? null : addPost,
                child: isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Publish",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}