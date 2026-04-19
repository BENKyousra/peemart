import 'package:flutter/material.dart';
import 'products/add_product_page.dart';
import '../widgets/dashboard/dashboard_header.dart';
import '../widgets/dashboard/dashboard_menu.dart';
import '../widgets/dashboard/products_section.dart';
import '../widgets/dashboard/orders_section.dart';
import '../widgets/dashboard/promos_section.dart';
import '../widgets/dashboard/stats_section.dart';
import '../services/shop_service.dart';

class SellerDashboardPage extends StatefulWidget {
  final Map<String, dynamic> profile;

  const SellerDashboardPage({super.key, required this.profile});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  int index = 0;

  Map<String, dynamic>? shop;
  bool isLoadingShop = true;

  @override
  void initState() {
    super.initState();
    loadShop();
  }

  Future<void> loadShop() async {
    final data = await ShopService().getMyShop();

    setState(() {
      shop = data;
      isLoadingShop = false;
    });
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
              'Tableau de bord',
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),

      body: Column(
        children: [
          DashboardHeader(
            username: widget.profile['username'] ?? '',
            coverUrl: shop?['cover_image'],
            avatarUrl: widget.profile['avatar_url'],
          ),
          DashboardMenu(
            currentIndex: index,
            onChanged: (i) {
              setState(() => index = i);
            },
          ),

          const Divider(),

          Expanded(child: _buildContent()),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          );
        },
        backgroundColor: const Color.fromARGB(255, 0, 2, 105),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    switch (index) {
      case 0:
        return const ProductsSection();
      case 1:
        return const OrdersSection();
      case 2:
        return const PromosSection();
      case 3:
        return const StatsSection();
      default:
        return const SizedBox();
    }
  }
}
