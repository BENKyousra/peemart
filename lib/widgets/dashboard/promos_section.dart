import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/promo_model.dart';
import '../../pages/products/add_promo_page.dart';

class PromosSection extends StatefulWidget {
  const PromosSection({super.key});

  @override
  State<PromosSection> createState() => _PromosSectionState();
}

class _PromosSectionState extends State<PromosSection> {
  final supabase = Supabase.instance.client;

  List<PromoModel> promos = [];
  bool isLoading = true;

  String? shopId;

  @override
  void initState() {
    super.initState();
    initData();
  }

  // 🔥 INIT DATA
  Future<void> initData() async {
    await fetchShopId();
    await fetchPromos();
  }

  // 🔐 GET SHOP ID
  Future<void> fetchShopId() async {
    final userId = supabase.auth.currentUser!.id;

    final shop = await supabase
        .from('shops')
        .select('id')
        .eq('owner_id', userId)
        .single();

    shopId = shop['id'];
  }

  // 🔥 GET PROMOS
  Future<void> fetchPromos() async {
    setState(() => isLoading = true);

    if (shopId == null) return;

    final res = await supabase
        .from('promotions')
        .select('*, products!inner(shop_id)')
        .eq('products.shop_id', shopId!);

    promos = (res as List)
        .map((e) => PromoModel.fromMap(e))
        .toList();

    setState(() => isLoading = false);
  }

  // 🗑 DELETE PROMO
  Future<void> deletePromo(String id) async {
    await supabase.from('promotions').delete().eq('id', id);
    fetchPromos();
  }

  // ⏳ CHECK EXPIRATION
  bool isExpired(PromoModel promo) {
    if (promo.expiresAt == null) return false;
    return DateTime.now().isAfter(promo.expiresAt!);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // 🔥 BUTTON AJOUT PROMO
        ElevatedButton(
          onPressed: shopId == null
              ? null
              : () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddPromoPage(shopId: shopId!),
                    ),
                  );
                  fetchPromos();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 0, 169, 191),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 3,
          ),
          child: const Text(
            "Ajouter Promotion",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        const SizedBox(height: 10),

        // 🔥 LIST PROMOS (IMPORTANT FIX SCROLL)
        promos.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: Text("Aucune promotion"),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: promos.length,
                itemBuilder: (context, index) {
                  final promo = promos[index];

                  return Card(
                    child: ListTile(
                      title: Text("${promo.code} - ${promo.discount}%"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Usage: ${promo.usedCount}/${promo.maxUsage}"),
                          Text(
                            isExpired(promo) ? "Expiré" : "Actif",
                            style: TextStyle(
                              color: isExpired(promo)
                                  ? const Color.fromARGB(255, 255, 10, 88)
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 255, 10, 88),
                        ),
                        onPressed: () => deletePromo(promo.id),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}