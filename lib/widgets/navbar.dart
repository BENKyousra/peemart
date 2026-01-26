import 'package:flutter/material.dart';
import '../pages/login_page.dart';

class NavBar extends StatelessWidget {
  final Function(String)? onSearch;
  final bool isConnected; // <-- true si l'utilisateur est connecté
  final String username; // nom de l'utilisateur
  final String avatarUrl; // URL ou asset de l'avatar
  final int notificationsCount;
  final int favoritesCount;
  final int cartCount;

  NavBar({
    this.onSearch,
    this.isConnected = false,
    this.username = '',
    this.avatarUrl = '',
    this.notificationsCount = 0,
    this.favoritesCount = 0,
    this.cartCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: EdgeInsets.symmetric(horizontal: 35, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ===== 1er étage : Logo + Connexion / Profil =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Logo à gauche
                  Image.asset('assets/images/logo.png', width: 38, height: 38),
                  SizedBox(width: 8),
                  // Texte PeeMart
                  Text(
                    'PeeMart',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Swansea',
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),

              // ===== À droite : bouton Connexion ou profil connecté =====
              isConnected
                  ? Row(
                    children: [
                      // ⚡ Icônes à gauche
                      _iconWithBadge(
                        icon: Icons.notifications,
                        count: notificationsCount,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      _iconWithBadge(
                        icon: Icons.favorite,
                        count: favoritesCount,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      _iconWithBadge(
                        icon: Icons.shopping_cart,
                        count: cartCount,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                      // ⚡ Profil à droite
                      CircleAvatar(
                        radius: 18,
                        backgroundImage:
                            avatarUrl.isNotEmpty
                                ? NetworkImage(avatarUrl)
                                : AssetImage('assets/images/logo.png')
                                    as ImageProvider,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  )
                  : ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    icon: const Icon(
                      Icons.person,
                      color: Color.fromARGB(255, 0, 2, 105),
                      size: 20,
                    ),
                    label: const Text(
                      'Connexion',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 2, 105),
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
            ],
          ),

          SizedBox(height: 20),

          // ===== 2ème étage : Navigation =====
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _navButton('Accueil'),
              _navButton('Boutiques'),
              _navButton('Influenceurs'),
              _navButton('Feedback'),
              _navButton('Concours'),
            ],
          ),

          SizedBox(height: 15),

          // ===== 3ème étage : Barre de recherche =====
          SizedBox(
            width: double.infinity,
            child: TextField(
              onSubmitted: (value) {
                if (onSearch != null) onSearch!(value);
              },
              decoration: InputDecoration(
                hintText: 'Rechercher un produit ou une boutique...',
                prefixIcon: Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  // ===== Fonction boutons de navigation =====
  Widget _navButton(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () {
          // TODO: Navigate to page correspondante
        },
        child: Text(title, style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  // ===== Fonction pour icône avec badge =====
  Widget _iconWithBadge({
    required IconData icon,
    required int count,
    required VoidCallback onPressed,
  }) {
    return Stack(
      children: [
        IconButton(onPressed: onPressed, icon: Icon(icon, color: Colors.white)),
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 10, 88),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
