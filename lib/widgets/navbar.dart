import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/login_page.dart';
import '../pages/profile_page.dart';

class NavBar extends StatefulWidget {
  final Function(String)? onSearch;

  const NavBar({super.key, this.onSearch});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final supabase = Supabase.instance.client;

  bool isConnected = false;
  String username = 'Utilisateur';
  String avatarUrl =
      'https://static.vecteezy.com/system/resources/previews/000/288/638/non_2x/broker-vector-icon.jpg';

  int notificationsCount = 0;
  int favoritesCount = 0;
  int cartCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();

    supabase.auth.onAuthStateChange.listen((data) {
      _loadUser();
    });
  }

  Future<void> _loadUser() async {
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        // Récupère les infos depuis la table "users"
        final data =
            await supabase.from('users').select().eq('id', user.id).single();

        setState(() {
          isConnected = true;
          username = data['username'] ?? 'Utilisateur';
          avatarUrl = data['avatar_url'] ?? avatarUrl;
          notificationsCount = data['notifications_count'] ?? 0;
          favoritesCount = data['favorites_count'] ?? 0;
          cartCount = data['cart_count'] ?? 0;
        });
      } catch (e) {
        // Si problème avec la table users, on met des valeurs par défaut
        setState(() {
          isConnected = true;
          username = user.email?.split('@').first ?? 'Utilisateur';
          avatarUrl = avatarUrl;
          notificationsCount = 0;
          favoritesCount = 0;
          cartCount = 0;
        });
      }
    } else {
      setState(() {
        isConnected = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final isConnected = supabase.auth.currentUser != null;

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
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/logo.png', width: 38, height: 38),
                  const SizedBox(width: 8),
                  const Text(
                    'PeeMart',
                    style: TextStyle(
                      fontFamily: 'Swansea',
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              isConnected ? _connectedUI() : _loginButton(),
            ],
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: TextField(
              onSubmitted: widget.onSearch,
              decoration: const InputDecoration(
                hintText: 'Rechercher un produit ou une boutique...',
                prefixIcon: Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _connectedUI() {
    return Row(
      children: [
        _iconWithBadge(Icons.notifications, notificationsCount),
        _iconWithBadge(Icons.favorite, favoritesCount),
        _iconWithBadge(Icons.shopping_cart, cartCount),
        const SizedBox(width: 16),
        GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfilePage()),
    );
  },
  child: Row(
    children: [
      CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(avatarUrl),
      ),
      const SizedBox(width: 8),
      Text(
        username,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          height: 1.2,
        ),
      ),
    ],
  ),
),

        
      ],
    );
  }

  Widget _loginButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      },
      icon: const Icon(Icons.person, color: Color.fromARGB(255, 0, 2, 105)),
      label: const Text(
        'Connexion',
        style: TextStyle(
          color: Color.fromARGB(255, 0, 2, 105),
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
    );
  }

  Widget _navButton(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () {},
        child: Text(title, style: const TextStyle(color: Colors.white , fontSize: 18)),
      ),
    );
  }

  Widget _iconWithBadge(IconData icon, int count) {
    return Stack(
      children: [
        IconButton(icon: Icon(icon, color: Colors.white), onPressed: () {}),
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: CircleAvatar(
              radius: 8,
              backgroundColor: const Color.fromARGB(255, 255, 10, 88),
              child: Text(
                '$count',
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
