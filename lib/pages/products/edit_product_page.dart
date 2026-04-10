import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class EditProductPage extends StatefulWidget {
  final Map product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final ProductService service = ProductService();

  late TextEditingController titleCtrl;
  late TextEditingController descCtrl;
  late TextEditingController priceCtrl;

  final TextEditingController colorCtrl = TextEditingController();
  final TextEditingController sizeCtrl = TextEditingController();
  final TextEditingController stockCtrl = TextEditingController();
  final TextEditingController variantPriceCtrl = TextEditingController();

  Uint8List? newImageBytes;

  List<Uint8List> newGalleryImages = [];
  List<String> existingGallery = [];

  List<Map<String, dynamic>> variants = [];

  @override
  void initState() {
    super.initState();

    titleCtrl = TextEditingController(text: widget.product['title']);
    descCtrl = TextEditingController(text: widget.product['description']);
    priceCtrl =
        TextEditingController(text: widget.product['price'].toString());

    loadGallery();
    loadVariants();
  }

  // ================= LOAD =================

  Future<void> loadGallery() async {
    final res = await service.supabase
        .from('product_images')
        .select('image_url')
        .eq('product_id', widget.product['id']);

    setState(() {
      existingGallery =
          List<String>.from(res.map((e) => e['image_url']));
    });
  }

  Future<void> loadVariants() async {
    final res = await service.supabase
        .from('product_variants')
        .select()
        .eq('product_id', widget.product['id']);

    setState(() {
      variants = List<Map<String, dynamic>>.from(res);
    });
  }

  // ================= IMAGE =================

  Future<void> pickMainImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => newImageBytes = bytes);
    }
  }

  Future<void> pickGalleryImages() async {
    final picked = await ImagePicker().pickMultiImage();

    if (picked != null) {
      final bytesList =
          await Future.wait(picked.map((e) => e.readAsBytes()));

      setState(() => newGalleryImages.addAll(bytesList));
    }
  }

  // ================= UPDATE =================

  Future<void> updateProduct() async {
    String? mainImage = widget.product['image'];

    if (newImageBytes != null) {
      mainImage = await service.uploadImage(newImageBytes!);
    }

    // upload nouvelles images
    List<String> uploadedGallery = [];
    for (var img in newGalleryImages) {
      final url = await service.uploadImage(img);
      uploadedGallery.add(url);
    }

    await service.updateProduct(
      id: widget.product['id'],
      title: titleCtrl.text,
      description: descCtrl.text,
      price: double.parse(priceCtrl.text),
      image: mainImage,
    );

    // ajouter nouvelles images
    await service.addImages(
      productId: widget.product['id'],
      images: uploadedGallery,
    );

    // update variantes
    await service.updateVariants(
      productId: widget.product['id'],
      variants: variants,
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier produit")),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              // ================= IMAGE PRINCIPALE =================
              GestureDetector(
                onTap: pickMainImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: newImageBytes != null
                      ? Image.memory(newImageBytes!, fit: BoxFit.cover)
                      : widget.product['image'] != null
                          ? Image.network(widget.product['image'],
                              fit: BoxFit.cover)
                          : const Icon(Icons.add_a_photo),
                ),
              ),

              const SizedBox(height: 15),

              // ================= INFOS =================
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Titre"),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Prix"),
              ),

              const SizedBox(height: 20),

              // ================= GALLERY =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Galerie"),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: pickGalleryImages,
                  ),
                ],
              ),

              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [

                    // EXISTING
                    ...existingGallery.map((img) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(5),
                            width: 100,
                            child: Image.network(img, fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: () async {
                                await service.deleteSingleImage(
                                  productId: widget.product['id'],
                                  imageUrl: img,
                                );

                                setState(() {
                                  existingGallery.remove(img);
                                });
                              },
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    // NEW
                    ...newGalleryImages.map((img) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(5),
                            width: 100,
                            child: Image.memory(img, fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  newGalleryImages.remove(img);
                                });
                              },
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= VARIANTS =================
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Variantes",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),

              Column(
                children: variants.map((v) {
                  return ListTile(
                    title: Text(
                        "${v['color'] ?? ''} / ${v['size'] ?? ''}"),
                    subtitle: Text(
                        "Stock: ${v['stock']} | Prix: ${v['price']}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          variants.remove(v);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 10),

              // ADD VARIANT
              TextField(
                controller: colorCtrl,
                decoration: const InputDecoration(labelText: "Couleur"),
              ),
              TextField(
                controller: sizeCtrl,
                decoration: const InputDecoration(labelText: "Taille"),
              ),
              TextField(
                controller: stockCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Stock"),
              ),
              TextField(
                controller: variantPriceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Prix variante"),
              ),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    variants.add({
                      'color': colorCtrl.text,
                      'size': sizeCtrl.text,
                      'stock': int.tryParse(stockCtrl.text) ?? 0,
                      'price':
                          double.tryParse(variantPriceCtrl.text) ?? 0,
                    });
                  });
                },
                child: const Text("Ajouter variante"),
              ),

              const SizedBox(height: 20),

              // SAVE
              ElevatedButton(
                onPressed: updateProduct,
                child: const Text("Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}