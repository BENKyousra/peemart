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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _item(Icons.store, "Produits", 0),
        _item(Icons.shopping_bag, "Commandes", 1),
        _item(Icons.local_offer, "Promos", 2),
        _item(Icons.bar_chart, "Stats", 3),
      ],
    );
  }

  Widget _item(IconData icon, String label, int i) {
    final isActive = currentIndex == i;

    return GestureDetector(
      onTap: () => onChanged(i),
      child: Column(
        children: [
          Icon(
            icon,
            color: isActive ? Colors.blue : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.blue : Colors.grey,
              fontWeight:
                  isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}