import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  void copyEmail(BuildContext context, String email) {
    Clipboard.setData(ClipboardData(text: email));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Email copié dans le presse-papiers"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget emailItem(
      BuildContext context, String name, String email) {
    return GestureDetector(
      onTap: () => copyEmail(context, email),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.attach_email_rounded,
            color: Colors.white70,
            size: 16,
          ),
          const SizedBox(width: 5),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white70,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "© 2026 Peemart - Tous droits réservés",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),

          const SizedBox(height: 10),

          const Text(
            "Conception du projet : Belhouari Amina",
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 15),

          // 👇 EMAILS CLIQUABLES
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
            "Realisé par : ",
            style: TextStyle(color: Colors.white70),
          ),
              emailItem(
                context,
                "Benkredda Yousra",
                "benkredda.yousra@email.com",
              ),
              const Text(
                "  &  ",
                style: TextStyle(color: Colors.white70),
              ),
              emailItem(
                context,
                "Bousmaha Hafsa",
                "bousmahahafsa52@gmail.com",
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            "Encadré par : Diouani Hala & Meradi Samir",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}