import 'package:flutter/material.dart';
import 'shop_page.dart';
import '../../services/shop_service.dart';
import '../../widgets/navbar.dart';

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

  final ScrollController _scrollController = ScrollController();
  double scrollOffset = 0;

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

    // 🔥 CONNECT SCROLL
    _scrollController.addListener(() {
      setState(() {
        scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 🔄 LOAD SHOPS
  Future<void> loadShops() async {
    setState(() => loading = true);

    shops = await _service.getAllShops();

    setState(() => loading = false);
  }

  // 📍 FILTER WILAYA
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

  // 🔍 SEARCH FILTER
  List<Map<String, dynamic>> get filteredShops {
    if (searchQuery.isEmpty) return shops;

    return shops.where((s) {
      return (s['name'] ?? '').toString().toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          // 🔥 NAVBAR CONNECTÉ
          NavBar(scrollOffset: scrollOffset),

          // 📦 CONTENT
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadShops,

              child:
                  loading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                        controller: _scrollController, // 🔥 IMPORTANT
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),

                        children: [
                          // 🌍 FILTER WILAYA
                          DropdownButton<String>(
                            value: selectedWilaya,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            iconEnabledColor: Colors.blue,

                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),

                            items:
                                wilayas.map((w) {
                                  return DropdownMenuItem(
                                    value: w,
                                    child: Text(w),
                                  );
                                }).toList(),

                            onChanged: (value) {
                              if (value != null) {
                                filterByWilaya(value);
                              }
                            },
                          ),

                          const SizedBox(height: 10),

                          // 🏪 LIST SHOPS
                          ...filteredShops.map((shop) {
                            return Card(
                              elevation: 2,
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(vertical: 6),

                              child: ListTile(
                                onTap: () {
  final id = shop['id'];

  if (id == null) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ShopPage(shopId: id.toString()),
    ),
  );
},
                                leading: CircleAvatar(
                                  backgroundImage:
                                      shop['avatar'] != null &&
                                              shop['avatar']
                                                  .toString()
                                                  .isNotEmpty
                                          ? NetworkImage(shop['avatar'])
                                          : null,
                                  child:
                                      shop['avatar'] == null ||
                                              shop['avatar'].toString().isEmpty
                                          ? const Icon(Icons.store)
                                          : null,
                                ),

                                title: Text(shop['name'] ?? ''),
                                subtitle: Text("📍 ${shop['location'] ?? ''}"),
                              ),
                            );
                          }),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
