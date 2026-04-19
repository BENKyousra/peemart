import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPromoPage extends StatefulWidget {
  final String shopId;

  const AddPromoPage({super.key, required this.shopId});

  @override
  State<AddPromoPage> createState() => _AddPromoPageState();
}

class _AddPromoPageState extends State<AddPromoPage> {
  final supabase = Supabase.instance.client;

  final codeController = TextEditingController();
  final discountController = TextEditingController();
  final maxUsageController = TextEditingController();

  List products = [];
  String? selectedProductId;

  DateTime? expiresAt;
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  // 🔥 Charger uniquement produits de la boutique
  Future<void> fetchProducts() async {
    final res = await supabase
        .from('products')
        .select('id, title')
        .eq('shop_id', widget.shopId);

    setState(() {
      products = res;
      isLoading = false;
    });
  }

  // 📅 choisir date
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => expiresAt = picked);
    }
  }

  // 🚀 ajouter promo
  Future<void> addPromo() async {
    if (selectedProductId == null ||
        codeController.text.isEmpty ||
        discountController.text.isEmpty ||
        maxUsageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Remplir tous les champs")),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      await supabase.from('promotions').insert({
        'product_id': selectedProductId,
        'code': codeController.text.trim().toUpperCase(),
        'discount': double.parse(discountController.text),
        'max_usage': int.parse(maxUsageController.text),
        'used_count': 0,
        'expires_at': expiresAt?.toIso8601String(),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    }

    setState(() => isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter Promotion"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 🔽 PRODUITS (filtrés par shop)
                  DropdownButtonFormField<String>(
                    value: selectedProductId,
                    hint: const Text("Choisir un produit"),
                    items: products.map<DropdownMenuItem<String>>((product) {
                      return DropdownMenuItem<String>(
                        value: product['id'],
                        child: Text(product['title']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedProductId = value);
                    },
                  ),

                  const SizedBox(height: 15),

                  // 🏷 CODE
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: "Code Promo",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 💸 DISCOUNT
                  TextField(
                    controller: discountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Discount (%)",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 🔢 MAX USAGE
                  TextField(
                    controller: maxUsageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Max utilisation",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 📅 DATE
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          expiresAt == null
                              ? "Pas de date d'expiration"
                              : "Expire: ${expiresAt!.toLocal().toString().split(' ')[0]}",
                        ),
                      ),
                      TextButton(
                        onPressed: pickDate,
                        child: const Text("Choisir date"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // 🚀 BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : addPromo,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                        backgroundColor:
                            const Color.fromARGB(255, 0, 2, 105),
                      ),
                      child: isSaving
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : const Text(
                              "Créer Promotion",
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