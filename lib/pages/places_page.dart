import 'package:flutter/material.dart';
import '../../pages/shop_page.dart';
import '../services/shop_service.dart';
import '../widgets/navbar.dart';


class PlacesPage extends StatefulWidget {
  const PlacesPage({super.key});

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  final ShopService _service = ShopService();

  List<Map<String, dynamic>> shops = [];
  bool loading = true;

  String selectedWilaya = "All";
  String searchQuery = "";

  final List<String> wilayas = [
    "All",
    "Tlemcen",
    "Oran",
    "Alger",
    "Sidi Bel Abbès",
    "Constantine",
    "Annaba",
  ];

  @override
  void initState() {
    super.initState();
    loadShops();
  }

  // 🔄 LOAD ALL SHOPS
  Future<void> loadShops() async {
    setState(() => loading = true);

    shops = await _service.getAllShops();

    setState(() => loading = false);
  }

  // 📍 FILTER BY WILAYA
  Future<void> filterByWilaya(String wilaya) async {
    setState(() {
      selectedWilaya = wilaya;
      loading = true;
    });

    shops =
        wilaya == "All"
            ? await _service.getAllShops()
            : await _service.getShopsByWilaya(wilaya);

    setState(() => loading = false);
  }

  // 🔍 SEARCH LOCAL FILTER (UI only)
  List<Map<String, dynamic>> get filteredShops {
    List<Map<String, dynamic>> result = shops;

    if (searchQuery.isNotEmpty) {
      result =
          result
              .where(
                (s) => (s['name'] ?? '').toString().toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
              )
              .toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          // 🧭 NAVBAR
          const NavBar(),

          // 📦 CONTENT
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadShops,

              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),

                children: [
                DropdownButton<String>(
  value: selectedWilaya,
  isExpanded: true,
  dropdownColor: Colors.white, // fond menu

  iconEnabledColor: Colors.blue, // icône

  style: const TextStyle(
    color: Colors.black,
    fontSize: 16,
  ),

  items: wilayas.map((w) {
    return DropdownMenuItem(
      value: w,
      child: Text(
        w,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }).toList(),

  onChanged: (value) {
    if (value != null) {
      filterByWilaya(value);
    }
  },
),

                  const SizedBox(height: 10),

                  // ⏳ LOADING
                  if (loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    // 🏪 LIST SHOPS
                    ...filteredShops.map((shop) {
                      return Card(
  elevation: 2,
  margin: const EdgeInsets.symmetric(vertical: 6),
  child: ListTile(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShopPage(shopId: shop['id']),
        ),
      );
    },

    leading: CircleAvatar(
      backgroundImage: shop['avatar'] != null &&
              shop['avatar'].toString().isNotEmpty
          ? NetworkImage(shop['avatar'])
          : null,
      child: shop['avatar'] == null ||
              shop['avatar'].toString().isEmpty
          ? const Icon(Icons.store)
          : null,
    ),

    title: Text(shop['name'] ?? ''),
    subtitle: Text("📍 ${shop['location'] ?? ''}"),
  ),
);
                    }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
