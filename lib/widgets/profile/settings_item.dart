import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final String? value;
  final VoidCallback onTap;
  final Color? color;

  const SettingsItem({
    super.key,
    required this.title,
    this.value,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 TEXTE PRINCIPAL PREND TOUT L’ESPACE
            Expanded(
              flex: 3,
              child: Text(
                title,
                softWrap: true,
                style: TextStyle(
                  fontSize: 16,
                  color: color ?? Color.fromARGB(255, 0, 2, 105),
                ),
              ),
            ),

            if (value != null) ...[
              const SizedBox(width: 12),

              // 🔥 VALEUR RESPONSIVE
              Expanded(
                flex: 2,
                child: Text(
                  value!,
                  softWrap: true,
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}
