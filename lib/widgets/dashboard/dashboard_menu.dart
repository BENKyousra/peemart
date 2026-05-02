import 'package:flutter/material.dart';

class DashboardMenu extends StatelessWidget {
  final int currentIndex;
  final Function(int) onChanged;

  const DashboardMenu({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(Icons.store, "Produits", 0),
          _item(Icons.shopping_bag, "Commandes", 1),
          _item(Icons.local_offer, "Promos", 2),
          _item(Icons.local_shipping, "Livraison", 3),
          _item(Icons.bar_chart, "Stats", 4),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, int i) {
    final isActive = currentIndex == i;
    const primaryColor = Color.fromARGB(255, 0, 169, 191);

    return GestureDetector(
      onTap: () => onChanged(i),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? primaryColor : Colors.grey,
            size: 22,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: isActive ? primaryColor : Colors.grey,
              fontWeight:
                  isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
