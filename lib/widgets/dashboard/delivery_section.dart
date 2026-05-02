import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/delivery_model.dart';

class DeliverySection extends StatefulWidget {
  const DeliverySection({super.key});

  @override
  State<DeliverySection> createState() => _DeliverySectionState();
}

class _DeliverySectionState extends State<DeliverySection> {
  final supabase = Supabase.instance.client;

  static const primaryColor = Color.fromARGB(255, 0, 169, 191);
  static const darkBlue = Color.fromARGB(255, 0, 1, 59);

  String? shopId;
  bool isLoading = true;

  // Toutes les entreprises disponibles dans la plateforme
  List<DeliveryCompanyModel> allCompanies = [];

  // IDs des entreprises déjà liées à ce shop
  Set<String> linkedCompanyIds = {};

  // Map linkId → companyId (pour pouvoir supprimer)
  Map<String, String> linkIdToCompanyId = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      // 1. Récupérer le shop du vendeur
      final userId = supabase.auth.currentUser!.id;
      final shop = await supabase
          .from('shops')
          .select('id')
          .eq('owner_id', userId)
          .single();
      shopId = shop['id'];

      // 2. Toutes les entreprises de livraison actives
      final companies = await supabase
          .from('delivery_companies')
          .select()
          .eq('is_active', true)
          .order('name');

      allCompanies = (companies as List)
          .map((e) => DeliveryCompanyModel.fromJson(e))
          .toList();

      // 3. Entreprises déjà liées à ce shop
      final links = await supabase
          .from('shop_delivery_companies')
          .select()
          .eq('shop_id', shopId!);

      linkedCompanyIds = {};
      linkIdToCompanyId = {};
      for (final link in links as List) {
        final companyId = link['delivery_company_id'] as String;
        final linkId = link['id'] as String;
        linkedCompanyIds.add(companyId);
        linkIdToCompanyId[companyId] = linkId;
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _toggleCompany(DeliveryCompanyModel company) async {
    if (shopId == null) return;

    if (linkedCompanyIds.contains(company.id)) {
      // Supprimer le lien
      final linkId = linkIdToCompanyId[company.id];
      if (linkId != null) {
        await supabase
            .from('shop_delivery_companies')
            .delete()
            .eq('id', linkId);
      }
      setState(() {
        linkedCompanyIds.remove(company.id);
        linkIdToCompanyId.remove(company.id);
      });
      _showSnack('${company.name} retiré de votre boutique');
    } else {
      // Ajouter le lien
      final res = await supabase
          .from('shop_delivery_companies')
          .insert({
            'shop_id': shopId!,
            'delivery_company_id': company.id,
            'is_default': linkedCompanyIds.isEmpty, // 1er = default
          })
          .select()
          .single();

      setState(() {
        linkedCompanyIds.add(company.id);
        linkIdToCompanyId[company.id] = res['id'];
      });
      _showSnack('${company.name} ajouté à votre boutique ✅');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showAddCompanyDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final stdPriceCtrl = TextEditingController();
    final expPriceCtrl = TextEditingController();
    final stdDelayCtrl = TextEditingController(text: '3-5 jours');
    final expDelayCtrl = TextEditingController(text: '24h');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '➕ Proposer un livreur',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(nameCtrl, 'Nom de l\'entreprise', Icons.business),
              const SizedBox(height: 10),
              _dialogField(phoneCtrl, 'Téléphone', Icons.phone,
                  type: TextInputType.phone),
              const SizedBox(height: 10),
              _dialogField(descCtrl, 'Description (optionnel)', Icons.info_outline),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _dialogField(
                        stdPriceCtrl, 'Prix standard (DA)', Icons.payments,
                        type: TextInputType.number),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _dialogField(
                        expPriceCtrl, 'Prix express (DA)', Icons.flash_on,
                        type: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _dialogField(
                        stdDelayCtrl, 'Délai standard', Icons.schedule),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _dialogField(
                        expDelayCtrl, 'Délai express', Icons.bolt),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(context);

              // Insérer la nouvelle entreprise
              final res = await supabase
                  .from('delivery_companies')
                  .insert({
                    'name': nameCtrl.text.trim(),
                    'phone': phoneCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'price_standard':
                        double.tryParse(stdPriceCtrl.text) ?? 0,
                    'price_express':
                        double.tryParse(expPriceCtrl.text) ?? 0,
                    'delay_standard': stdDelayCtrl.text.trim(),
                    'delay_express': expDelayCtrl.text.trim(),
                    'is_active': true,
                  })
                  .select()
                  .single();

              // Lier automatiquement au shop
              final linkRes = await supabase
                  .from('shop_delivery_companies')
                  .insert({
                    'shop_id': shopId!,
                    'delivery_company_id': res['id'],
                    'is_default': linkedCompanyIds.isEmpty,
                  })
                  .select()
                  .single();

              await _loadData();
              _showSnack('Livreur ajouté et lié à votre boutique ✅');
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        isDense: true,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

 @override
Widget build(BuildContext context) {
  if (isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  return RefreshIndicator(
    onRefresh: _loadData,

    // 🔥 IMPORTANT: un seul scroll global
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── HEADER ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🚚 Entreprises de livraison',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Activez les livreurs disponibles pour votre boutique',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: _showAddCompanyDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Nouveau', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── RÉSUMÉ ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${linkedCompanyIds.length} livreur(s) actif(s) sur votre boutique',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ─── LISTE ─────────────────────────────
          allCompanies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      const Icon(Icons.local_shipping_outlined,
                          size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text(
                        'Aucune entreprise disponible',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddCompanyDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter le premier livreur'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: allCompanies.length,
                  itemBuilder: (context, index) {
                    final company = allCompanies[index];
                    final isLinked =
                        linkedCompanyIds.contains(company.id);

                    return _buildCompanyCard(company, isLinked);
                  },
                ),
        ],
      ),
    ),
  );
}
  Widget _buildCompanyCard(DeliveryCompanyModel company, bool isLinked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLinked ? primaryColor : Colors.grey.shade200,
          width: isLinked ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── ROW PRINCIPALE ─────────────────────────
            Row(
              children: [
                // Logo ou icône
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isLinked
                        ? primaryColor.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: company.logoUrl != null &&
                          company.logoUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            company.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.local_shipping,
                              color: isLinked
                                  ? primaryColor
                                  : Colors.grey,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.local_shipping,
                          color:
                              isLinked ? primaryColor : Colors.grey,
                        ),
                ),

                const SizedBox(width: 12),

                // Nom + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isLinked
                              ? const Color.fromARGB(255, 0, 1, 59)
                              : Colors.black87,
                        ),
                      ),
                      if (company.description != null &&
                          company.description!.isNotEmpty)
                        Text(
                          company.description!,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (company.phone != null)
                        Text(
                          company.phone!,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),

                // Toggle Switch
                Switch(
                  value: isLinked,
                  onChanged: (_) => _toggleCompany(company),
                  activeColor: primaryColor,
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // ─── TARIFS ─────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _tariffChip(
                    icon: Icons.local_shipping_outlined,
                    label: 'Standard',
                    price: '${company.priceStandard.toStringAsFixed(0)} DA',
                    delay: company.delayStandard,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _tariffChip(
                    icon: Icons.flash_on,
                    label: 'Express',
                    price: '${company.priceExpress.toStringAsFixed(0)} DA',
                    delay: company.delayExpress,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tariffChip({
    required IconData icon,
    required String label,
    required String price,
    required String delay,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color)),
                Text(price,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold)),
                Text(delay,
                    style: const TextStyle(
                        fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
