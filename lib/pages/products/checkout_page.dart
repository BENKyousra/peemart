import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/cart_model.dart';
import '../../models/delivery_model.dart';
import '../../services/delivery_service.dart';
import '../../services/order_service.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartModel> cartItems;
  final double subtotal;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.subtotal,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final deliveryService = DeliveryService();
  final orderService = OrderService();

  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();

  // 🚚 Livraison
  Map<String, List<DeliveryCompanyModel>> shopDeliveryMap = {};
  Map<String, DeliveryCompanyModel?> selectedCompanyPerShop = {};
  Map<String, String> selectedTypePerShop = {}; // 'standard' ou 'express'

  bool isLoading = true;
  bool isOrdering = false;

  // Shops distincts dans le panier
  List<String> get shopIds =>
      widget.cartItems.map((e) => e.shopId).toSet().toList();

  @override
  void initState() {
    super.initState();
    _loadDeliveryCompanies();
  }

  Future<void> _loadDeliveryCompanies() async {
    setState(() => isLoading = true);
    try {
      final map = await deliveryService.getDeliveryCompaniesForShops(shopIds);
      setState(() {
        shopDeliveryMap = map;
        // Init sélection par défaut
        for (final shopId in shopIds) {
          final companies = map[shopId] ?? [];
          selectedCompanyPerShop[shopId] =
              companies.isNotEmpty ? companies.first : null;
          selectedTypePerShop[shopId] = 'standard';
        }
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  double get totalDeliveryPrice {
    double total = 0;
    for (final shopId in shopIds) {
      final company = selectedCompanyPerShop[shopId];
      final type = selectedTypePerShop[shopId] ?? 'standard';
      if (company != null) {
        total +=
            type == 'express' ? company.priceExpress : company.priceStandard;
      }
    }
    return total;
  }

  double get grandTotal => widget.subtotal + totalDeliveryPrice;

  // Groupe les items par shop
  Map<String, List<CartModel>> get itemsByShop {
    final Map<String, List<CartModel>> map = {};
    for (final item in widget.cartItems) {
      map.putIfAbsent(item.shopId, () => []).add(item);
    }
    return map;
  }

  Future<void> _placeOrder() async {
    // Validation
    if (_addressController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      _showSnack('Veuillez remplir tous les champs d\'adresse', isError: true);
      return;
    }

    for (final shopId in shopIds) {
      if (selectedCompanyPerShop[shopId] == null) {
        _showSnack('Veuillez choisir un livreur pour chaque shop',
            isError: true);
        return;
      }
    }

    setState(() => isOrdering = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      // Passer une commande par shop
      for (final shopId in shopIds) {
        final company = selectedCompanyPerShop[shopId]!;
        final type = selectedTypePerShop[shopId] ?? 'standard';
        final price =
            type == 'express' ? company.priceExpress : company.priceStandard;
        final delay =
            type == 'express' ? company.delayExpress : company.delayStandard;

        await orderService.checkout(
          userId: userId,
          deliveryCompanyId: company.id,
          deliveryCompanyName: company.name,
          deliveryType: type,
          deliveryAddress: _addressController.text.trim(),
          deliveryCity: _cityController.text.trim(),
          deliveryPhone: _phoneController.text.trim(),
          deliveryPrice: price,
          estimatedDelivery: delay,
          shopId: shopId,
        );
      }

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      _showSnack('Erreur lors de la commande: $e', isError: true);
    } finally {
      if (mounted) setState(() => isOrdering = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 70),
            const SizedBox(height: 16),
            const Text(
              'Commande passée !',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vous recevrez une notification avec les détails de votre livraison.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromARGB(255, 0, 169, 191);
    const darkBlue = Color.fromARGB(255, 0, 1, 59);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [darkBlue, Color.fromARGB(255, 0, 2, 105)],
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Finaliser la commande',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── ADRESSE ───────────────────────────────
                  _sectionTitle('📍 Adresse de livraison'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Adresse complète',
                    icon: Icons.home_outlined,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _cityController,
                    label: 'Ville / Wilaya',
                    icon: Icons.location_city_outlined,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Numéro de téléphone',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 24),

                  // ─── LIVRAISON PAR SHOP ─────────────────────
                  _sectionTitle('🚚 Livraison'),
                  const SizedBox(height: 12),

                  ...shopIds.map((shopId) {
                    final shopItems = itemsByShop[shopId] ?? [];
                    final shopName = shopItems.isNotEmpty
                        ? shopItems.first.shopName
                        : 'Shop';
                    final companies = shopDeliveryMap[shopId] ?? [];

                    return _buildShopDeliveryCard(
                      shopId: shopId,
                      shopName: shopName,
                      companies: companies,
                      primaryColor: primaryColor,
                    );
                  }),

                  const SizedBox(height: 24),

                  // ─── RÉSUMÉ ─────────────────────────────────
                  _sectionTitle('🧾 Résumé'),
                  const SizedBox(height: 12),
                  _buildSummaryCard(primaryColor),

                  const SizedBox(height: 30),

                  // ─── BOUTON COMMANDER ───────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isOrdering ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isOrdering
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Commander • ${grandTotal.toStringAsFixed(0)} DA',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildShopDeliveryCard({
    required String shopId,
    required String shopName,
    required List<DeliveryCompanyModel> companies,
    required Color primaryColor,
  }) {
    final selected = selectedCompanyPerShop[shopId];
    final selectedType = selectedTypePerShop[shopId] ?? 'standard';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop name
            Row(
              children: [
                const Icon(Icons.store, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  shopName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (companies.isEmpty)
              const Text(
                '⚠️ Aucune entreprise de livraison disponible pour ce shop',
                style: TextStyle(color: Colors.orange),
              )
            else ...[
              // Choix de l'entreprise
              if (companies.length > 1) ...[
                const Text(
                  'Choisir le livreur :',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ...companies.map((company) => _buildCompanyTile(
                      company: company,
                      shopId: shopId,
                      isSelected: selected?.id == company.id,
                      primaryColor: primaryColor,
                    )),
              ] else ...[
                // Une seule entreprise → affichée directement
                Row(
                  children: [
                    const Icon(Icons.local_shipping, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      companies.first.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Assigné',
                        style: TextStyle(
                            color: primaryColor, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              // Type de livraison
              const Text(
                'Type de livraison :',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTypeChip(
                    label: 'Standard',
                    subtitle: selected != null
                        ? '${selected.priceStandard.toStringAsFixed(0)} DA • ${selected.delayStandard}'
                        : '',
                    isSelected: selectedType == 'standard',
                    onTap: () => setState(
                        () => selectedTypePerShop[shopId] = 'standard'),
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(width: 10),
                  _buildTypeChip(
                    label: 'Express',
                    subtitle: selected != null
                        ? '${selected.priceExpress.toStringAsFixed(0)} DA • ${selected.delayExpress}'
                        : '',
                    isSelected: selectedType == 'express',
                    onTap: () => setState(
                        () => selectedTypePerShop[shopId] = 'express'),
                    primaryColor: primaryColor,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyTile({
    required DeliveryCompanyModel company,
    required String shopId,
    required bool isSelected,
    required Color primaryColor,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() => selectedCompanyPerShop[shopId] = company);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (company.logoUrl != null && company.logoUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  company.logoUrl!,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.local_shipping,
                      size: 36),
                ),
              )
            else
              const Icon(Icons.local_shipping, size: 36, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? primaryColor : Colors.black87,
                    ),
                  ),
                  if (company.description != null)
                    Text(
                      company.description!,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: primaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip({
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withOpacity(0.1)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? primaryColor : Colors.black87,
                  fontSize: 13,
                ),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style:
                      const TextStyle(fontSize: 11, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow(
              'Sous-total produits',
              '${widget.subtotal.toStringAsFixed(0)} DA'),
          const SizedBox(height: 8),
          _summaryRow(
              'Frais de livraison',
              '${totalDeliveryPrice.toStringAsFixed(0)} DA'),
          const Divider(height: 20),
          _summaryRow(
            'Total',
            '${grandTotal.toStringAsFixed(0)} DA',
            isBold: true,
            color: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight:
                    isBold ? FontWeight.bold : FontWeight.normal)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 17 : 14,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 0, 169, 191), width: 2),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 0, 1, 59),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
