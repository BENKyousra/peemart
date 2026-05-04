import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/profile/profile_settings.dart';
import '../../widgets/profile/profile_info.dart';
import '../../models/product_model.dart';

class ProfileLayout extends StatefulWidget {
  final bool isSeller;
  final Function(bool) updateSeller;
  final Future<void> Function() logout;

  final String avatarUrl;
  final String username;
  final String email;
  final String bio;
  final Function(String, dynamic) updateField;
  final Future<String?> Function(XFile image) onAvatarChanged;

  const ProfileLayout({
    super.key,
    required this.isSeller,
    required this.updateSeller,
    required this.logout,
    required this.avatarUrl,
    required this.username,
    required this.email,
    required this.bio,
    required this.updateField,
    required this.onAvatarChanged,
  });

  @override
  State<ProfileLayout> createState() => _ProfileLayoutState();
}

class _ProfileLayoutState extends State<ProfileLayout> {
  final supabase = Supabase.instance.client;

  List<ProductModel> favorites = [];
  bool isLoadingFav = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  // =========================
  // 🔥 LOAD FAVORITES (SAME AS FAVORITES PAGE)
  // =========================
  Future<void> loadFavorites() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() => isLoadingFav = false);
      return;
    }

    try {
      final favs = await supabase
          .from('favorites')
          .select('product_id')
          .eq('user_id', user.id);

      final ids = List<String>.from(
        favs.map((e) => e['product_id'].toString()),
      );

      if (ids.isEmpty) {
        setState(() {
          favorites = [];
          isLoadingFav = false;
        });
        return;
      }

      final res = await supabase
          .from('products')
          .select('*, shops(*)')
          .in_('id', ids);

      setState(() {
        favorites =
            (res as List)
                .map((e) => ProductModel.fromMap(e))
                .toList();

        isLoadingFav = false;
      });
    } catch (e) {
      print("PROFILE FAVORITES ERROR: $e");
      setState(() => isLoadingFav = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== SETTINGS =====
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.topLeft,
              child: ProfileSettings(
                isSeller: widget.isSeller,
                updateSeller: widget.updateSeller,
                logout: widget.logout,
                deleteAccount: () async {
                  // 🔥 DELETE ACCOUNT
                  final user = supabase.auth.currentUser;
                  if (user == null) return;

                  try {
                    await supabase.from('users').delete().eq('id', user.id);
                    await supabase.auth.signOut();
                    widget.logout();
                  } catch (e) {
                    print("DELETE ACCOUNT ERROR: $e");
                  }
                },
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ===== INFO =====
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.topLeft,
              child: ProfileInfo(
                avatarUrl: widget.avatarUrl,
                username: widget.username,
                email: widget.email,
                bio: widget.bio,
                isSeller: widget.isSeller,
                favorites: favorites, // 🔥 IMPORTANT FIX
                updateField: widget.updateField,
                onAvatarChanged: widget.onAvatarChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}