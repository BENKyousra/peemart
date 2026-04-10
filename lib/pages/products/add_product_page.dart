import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/product_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();

  final picker = ImagePicker();
  final service = ProductService();

  Uint8List? mainImage;
  List<Uint8List> galleryImages = [];

  bool loading = false;

  // 🎨 Couleurs sélectionnées
  List<String> selectedColors = [];
  final List<String> availableColors = [
    "Noir",
    "Blanc",
    "Rouge",
    "Bleu",
    "Vert",
  ];

  // 📏 Tailles sélectionnées
  List<String> selectedSizes = [];
  final List<String> availableSizes = [
    "S",
    "M",
    "L",
    "XL",
  ];

  // 🔹 IMAGE PRINCIPALE
  Future<void> pickMainImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        mainImage = bytes;
      });
    }
  }

  // 🔹 GALERIE
  Future<void> pickGalleryImages() async {
    final picked = await picker.pickMultiImage();

    List<Uint8List> temp = [];

    for (var img in picked) {
      temp.add(await img.readAsBytes());
    }

    setState(() {
      galleryImages.addAll(temp);
    });
  }

  // 🔥 SUBMIT
  Future<void> submit() async {
  if (mainImage == null ||
      titleController.text.isEmpty ||
      descController.text.isEmpty ||
      priceController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Remplis tous les champs ❌")),
    );
    return;
  }

  setState(() => loading = true);

  try {
    // 🔹 upload image principale
    final mainUrl = await service.uploadImage(mainImage!);

    // 🔹 créer produit
    final productId = await service.createProduct(
      title: titleController.text,
      description: descController.text,
      price: double.parse(priceController.text),
      image: mainUrl,
      colors: selectedColors,
      sizes: selectedSizes,
    );

    // 🔥 GENERATE VARIANTS AUTOMATIQUEMENT
    List<Map<String, dynamic>> variants = [];

    if (selectedColors.isNotEmpty && selectedSizes.isNotEmpty) {
      for (var color in selectedColors) {
        for (var size in selectedSizes) {
          variants.add({
            'color': color,
            'size': size,
            'stock': 10, // 🔥 stock par défaut (tu peux changer)
            'price': double.parse(priceController.text),
          });
        }
      }
    } else {
      // 🔥 si pas de variantes
      variants.add({
        'color': null,
        'size': null,
        'stock': 10,
        'price': double.parse(priceController.text),
      });
    }

    // 🔹 sauvegarder variantes
    await service.updateVariants(
      productId: productId,
      variants: variants,
    );

    // 🔹 galerie
    List<String> galleryUrls = [];

    for (var img in galleryImages) {
      final url = await service.uploadImage(img);
      galleryUrls.add(url);
    }

    if (galleryUrls.isNotEmpty) {
      await service.addImages(
        productId: productId,
        images: galleryUrls,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produit ajouté ✅")),
    );

    Navigator.pop(context);
  } catch (e) {
    print("ERROR: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Erreur ❌")),
    );
  }

  setState(() => loading = false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter produit')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // TITLE
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Titre"),
            ),

            const SizedBox(height: 10),

            // DESCRIPTION
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 10),

            // PRICE
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Prix"),
            ),

            const SizedBox(height: 20),

            // IMAGE PRINCIPALE
            ElevatedButton.icon(
              onPressed: pickMainImage,
              icon: const Icon(Icons.image),
              label: const Text("Image principale"),
            ),

            const SizedBox(height: 10),

            if (mainImage != null)
              Image.memory(mainImage!, height: 120),

            const SizedBox(height: 20),

            // GALERIE
            ElevatedButton.icon(
              onPressed: pickGalleryImages,
              icon: const Icon(Icons.photo_library),
              label: const Text("Images galerie"),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              children: galleryImages
                  .map((img) => Image.memory(img, height: 80, width: 80))
                  .toList(),
            ),

            const SizedBox(height: 30),

            // 🎨 COULEURS
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Couleurs",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            Wrap(
              spacing: 10,
              children: availableColors.map((color) {
                final isSelected = selectedColors.contains(color);

                return FilterChip(
                  label: Text(color),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        selectedColors.add(color);
                      } else {
                        selectedColors.remove(color);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 📏 TAILLES
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Tailles",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            Wrap(
              spacing: 10,
              children: availableSizes.map((size) {
                final isSelected = selectedSizes.contains(size);

                return FilterChip(
                  label: Text(size),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        selectedSizes.add(size);
                      } else {
                        selectedSizes.remove(size);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            // BUTTON
            ElevatedButton(
              onPressed: loading ? null : submit,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Créer produit"),
            ),
          ],
        ),
      ),
    );
  }
}