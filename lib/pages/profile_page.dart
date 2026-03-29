import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import '../widgets/profile_settings.dart';
import '../widgets/profile_info.dart';
import '../services/profile_service.dart';
import '../models/profile_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  final ProfileService _service = ProfileService();
  ProfileModel? profile;
  bool isLoading = true;

  // Infos utilisateur
  String username = '';
  String email = '';
  static const String defaultAvatar =
      'https://res.cloudinary.com/diqymizc6YOUR_CLOUD_NAME/image/upload/v1/defaults/avatar.png';

  String avatarUrl = defaultAvatar;
  String bio = '';
  bool isSeller = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _service.getProfile();

      setState(() {
        profile = data;
        isLoading = false;
      });
    } catch (e) {
      print("❌ error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateField(String field, dynamic value) async {
    await _service.updateField(field, value);
    await _loadProfile();
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  //update avatar +++++++++++++++++++++++++++++++++++

  Future<String?> _updateAvatar(XFile image) async {
    final bytes = await image.readAsBytes();
    final url = await _service.uploadAvatar(bytes);

    if (url != null) {
      await _updateField('avatar_url', url);
      return url;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
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
          child: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Profil',
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // top align
          children: [
            // ===== Colonne paramètres =====
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.topLeft,
                child: ProfileSettings(
                  isSeller: profile!.isSeller,
                  updateSeller: (value) => _updateField('is_seller', value),
                  logout: () async {
                    await _service.logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (_) => false,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 8),

            // ===== Colonne infos =====
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.topLeft,
                child: ProfileInfo(
                  avatarUrl: profile!.avatarUrl,
                  username: profile!.username,
                  email: profile!.email,
                  isSeller: profile!.isSeller,
                  favorites: [],
                  bio: profile!.bio,
                  updateField: _updateField,
                  onAvatarChanged: _updateAvatar,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
