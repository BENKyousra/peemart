import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/login_page.dart';
import '../pages/profile_page.dart';
import '../pages/home_page.dart';
import '../pages/products/cart_page.dart';
import '../pages/seller_dashboard_page.dart';
import '../services/notification_service.dart';
import '../pages/notifications_page.dart';
import '../pages/favorites_page.dart';
import '../pages/influencer/influencer_dashboard.dart';
import '../pages/products/product_detail_page.dart';
import '../pages/shop_page.dart';
import '../../models/product_model.dart';

class NavBar extends StatefulWidget {
  final Function(String)? onSearch;
  final double scrollOffset;

  const NavBar({super.key, this.onSearch, required this.scrollOffset});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final supabase = Supabase.instance.client;
  final notifService = NotificationService();

  bool isConnected = false;
  String username = 'Utilisateur';
  String avatarUrl =
      'https://cdn.pixabay.com/photo/2023/02/18/11/00/icon-7797704_1280.png';

  int notificationsCount = 0;
  int favoritesCount = 0;
  int cartCount = 0;

  String currentPage = "Accueil";

  bool isSeller = false;
  bool isInfluencer = false;

  List<dynamic> productList = [];
  List<dynamic> shopList = [];

  @override
  void initState() {
    super.initState();
    _loadUser();

    supabase.auth.onAuthStateChange.listen((data) {
      _loadUser();
    });
  }

  Future<Map<String, dynamic>> searchAll(String query) async {
    final products = await supabase
    .from('products')
    .select('''
      *,
      shops (
        id,
        name,
        avatar
      ),
      product_images (
        image_url
      )
    ''')
    .or('title.ilike.%$query%,description.ilike.%$query%')
    .limit(20);

    final shops = await supabase
        .from('shops')
        .select()
        .ilike('name', '%$query%')
        .limit(10);

    return {'products': products, 'shops': shops};
  }

  final Map<String, String> routes = {
    "Accueil": "/home",
    "Dashboard": "/dashboard",
    "Places": "/places",
    "Influenceurs": "/influencers",
    "Feedback": "/feedback",
    "Concours": "/concours",
    "Favoris": "/favorites",
  };

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
          isSeller = data['is_seller'] ?? false;
          isInfluencer = data['is_influencer'] ?? false;
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

  void showSearchResults() {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            const Text(
              "Produits",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            ...productList.map((p) => ListTile(
              title: Text(p['title'] ?? ''),
              subtitle: Text('${p['price']} DA'),

              onTap: () {
                Navigator.pop(context); // fermer le bottom sheet

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailPage(
                      product: ProductModel.fromMap(p),
                    ),
                  ),
                );
              },
            )),

            const SizedBox(height: 10),

            const Text(
              "Boutiques",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            ...shopList.map((s) => ListTile(
              title: Text(s['name'] ?? ''),

              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShopPage(
                      shopId: s['id'],
                    ),
                  ),
                );
              },
            )),
          ],
        ),
      );
    },
  );
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔵 TOP BAR (toujours visible)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 38,
                      height: 38,
                    ),
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
              ),

              isConnected ? _connectedUI() : _loginButton(),
            ],
          ),

          // 🔥 NAV + SEARCH (disparaissent)
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState:
                widget.scrollOffset > 40
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            firstChild: Column(
              children: [
                const SizedBox(height: 20),

                // NAVIGATION
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _navButton('Accueil'),
                    _navButton('Places'),
                    _navButton('Influenceurs'),
                    _navButton('Feedback'),
                    _navButton('Concours'),
                  ],
                ),

                const SizedBox(height: 15),

                // SEARCH
                TextField(
                  onSubmitted: (value) async {
                    final result = await searchAll(value);

                    setState(() {
                      productList = result['products'];
                      shopList = result['shops'];
                    });

                    showSearchResults();
                  },
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
              ],
            ),

            secondChild: const SizedBox(height: 0),
          ),
        ],
      ),
    );
  }

  Widget _connectedUI() {
    return Row(
      children: [
        if (isSeller)
          IconButton(
            icon: const Icon(Icons.dashboard_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => SellerDashboardPage(
                        profile: {
                          "username": username,
                          "avatar_url": avatarUrl,
                        },
                      ),
                ),
              );
            },
          ),
        if (isInfluencer)
          IconButton(
            icon: const Icon(Icons.dashboard_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InfluencerDashboardPage(),
                ),
              );
            },
          ),
        StreamBuilder<int>(
          stream: notifService.unreadCount(supabase.auth.currentUser!.id),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;

            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsPage(),
                      ),
                    );
                  },
                ),

                if (count > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Color.fromARGB(255, 255, 10, 88),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.favorite, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesPage()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartPage()),
            );
          },
        ),
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
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isActive = currentRoute == routes[title];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, routes[title]!);
        },
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Color.fromARGB(255, 0, 169, 191) : Colors.white,
            fontSize: 19,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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
