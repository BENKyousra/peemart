import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

import '../services/shop_service.dart';
import '../widgets/dashboard/dashboard_header.dart';
import '../widgets/dashboard/dashboard_menu.dart';
import '../widgets/dashboard/products_section.dart';
import '../widgets/dashboard/orders_section.dart';
import '../widgets/dashboard/promos_section.dart';
import '../widgets/dashboard/stats_section.dart';
import '../widgets/dashboard/delivery_section.dart';
import 'products/add_product_page.dart';

class SellerDashboardPage extends StatefulWidget {
  final Map<String, dynamic> profile;

  const SellerDashboardPage({super.key, required this.profile});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  final ShopService service = ShopService();
  final ImagePicker _picker = ImagePicker();

  int index = 0;
  Map<String, dynamic>? shop;
  bool loading = true;

  final ScrollController scrollController = ScrollController();
  bool showHeader = true;

  @override
  void initState() {
    super.initState();
    loadShop();

    scrollController.addListener(() {
      if (scrollController.offset > 60 && showHeader) {
        setState(() => showHeader = false);
      } else if (scrollController.offset <= 60 && !showHeader) {
        setState(() => showHeader = true);
      }
    });
  }

  // =========================
  // 🔥 LOAD SHOP
  // =========================
  Future<void> loadShop() async {
    final data = await service.getMyShop();

    if (!mounted) return;

    setState(() {
      shop = data;
      loading = false;
    });
  }

  // =========================
  // 🔥 SAFE URL
  // =========================
  String? _safeUrl(dynamic url) {
    if (url == null) return null;
    if (url is! String) return null;
    if (url.isEmpty) return null;
    if (!url.startsWith('http')) return null;
    return url;
  }

  // =========================
  // 📸 PICK IMAGE (SAFE)
  // =========================
  Future<void> pickImage(Function(Uint8List bytes) onPicked) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();
    await onPicked(bytes);
  }

  // =========================
  // 👤 EDIT AVATAR
  // =========================
  Future<void> editAvatar() async {
    if (shop == null) return;

    await pickImage((bytes) async {
      await service.uploadShopAvatar(bytes, shop!['id']);
      await loadShop();
    });
  }

  // =========================
  // 🖼️ EDIT COVER
  // =========================
  Future<void> editCover() async {
    if (shop == null) return;

    await pickImage((bytes) async {
      await service.uploadShopCover(bytes, shop!['id']);
      await loadShop();
    });
  }

  Future<void> editName() async {
  if (shop == null) return;

  final controller = TextEditingController(text: shop!['name']);

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Modifier le nom"),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: "Nom de la boutique",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: () async {
            await service.updateShop(
              shopId: shop!['id'],
              name: controller.text,
            );

            Navigator.pop(context);
            await loadShop(); // 🔥 refresh
          },
          child: const Text("Sauvegarder"),
        ),
      ],
    ),
  );
}

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // =========================
      // APPBAR
      // =========================
      appBar: AppBar(
        title: const Text("Seller Dashboard"),
        backgroundColor: const Color.fromARGB(255, 0, 1, 59),
        foregroundColor: Colors.white,
      ),

      // =========================
      // BODY
      // =========================
      body: Column(
        children: [
          // =========================
          // HEADER
          // =========================
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: showHeader ? 170 : 0,
            child: showHeader
                ? DashboardHeader(
                    shopName: shop?['name'] ?? widget.profile['username'] ?? '',
                    coverUrl: _safeUrl(shop?['cover_image']),
                    avatarUrl: _safeUrl(shop?['avatar']),
                    onEditAvatar: editAvatar,
                    onEditCover: editCover,
                    onEditName: editName, 
                  )
                : null,
          ),

          // =========================
          // MENU
          // =========================
          DashboardMenu(
            currentIndex: index,
            onChanged: (i) => setState(() => index = i),
          ),

          const Divider(height: 1),

          // =========================
          // CONTENT
          // =========================
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: loading
                  ? const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _buildContent(),
            ),
          ),
        ],
      ),

      // =========================
      // ADD PRODUCT BUTTON
      // =========================
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductPage(),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 0, 2, 105),
        child: const Icon(Icons.add),
      ),
    );
  }

  // =========================
  // SECTIONS
  // =========================
  Widget _buildContent() {
    switch (index) {
      case 0:
        return const ProductsSection();
      case 1:
        return const OrdersSection();
      case 2:
        return const PromosSection();
      case 3:
        return const DeliverySection();
      case 4:
        return const StatsSection();
      default:
        return const SizedBox();
    }
  }
}