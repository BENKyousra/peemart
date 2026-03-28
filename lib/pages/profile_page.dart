import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import '../widgets/profile_settings.dart';
import '../widgets/profile_info.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;

  // Infos utilisateur
  String username = '';
  String email = '';
  static const String defaultAvatar =
      'https://res.cloudinary.com/diqymizc6YOUR_CLOUD_NAME/image/upload/v1/defaults/avatar.png';

  String avatarUrl = defaultAvatar;
  String bio = '';
  bool isSeller = false;
  List<dynamic> favorites = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final data =
          await supabase
              .from('profiles') // تأكد أن الجدول موجود
              .select()
              .eq('id', user.id)
              .single();

      setState(() {
        username = data['username'] ?? '';
        email = user.email ?? '';
        avatarUrl =
            data['avatar_url']?.toString().isNotEmpty == true
                ? data['avatar_url']
                : defaultAvatar;
        bio = data['bio'] ?? '';
        isSeller = data['is_seller'] ?? false;
        favorites = data['favorites'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Profile error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateField(String field, dynamic value) async {
    final user = supabase.auth.currentUser;
    if (value == null || value.toString().trim().isEmpty) return;
    if (user != null) {
      await supabase.from('profiles').update({field: value}).eq('id', user.id);
      await _loadProfile(); // الآن تنتظر إعادة تحميل البيانات
    }
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

  Future<void> _updateAvatarWeb(Uint8List bytes, String fileName) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/diqymizc6/image/upload',
      );

      final request =
          http.MultipartRequest('POST', uri)
            ..fields['upload_preset'] = 'avatars'
            ..fields['folder'] = 'avatars/${user.id}'
            ..files.add(
              http.MultipartFile.fromBytes('file', bytes, filename: fileName),
            );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);

      final imageUrl = data['secure_url'];

      // تحديث Supabase
      await supabase
          .from('profiles')
          .update({'avatar_url': imageUrl})
          .eq('id', user.id);

      await _loadProfile();
    } catch (e) {
      debugPrint('❌ Cloudinary upload error: $e');
    }
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
                  isSeller: isSeller,
                  updateSeller: (value) => _updateField('is_seller', value),
                  logout: _logout,
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
                  avatarUrl: avatarUrl,
                  username: username,
                  email: email,
                  isSeller: isSeller,
                  favorites: [
                    {
                      'title': 'Sac à dos',
                      'image_url':
                          'https://images.pexels.com/photos/15271715/pexels-photo-15271715.jpeg?_gl=1*1bjmyyf*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk1NTI0MzMkbzU1JGcxJHQxNzY5NTUyNzM3JGoyOSRsMCRoMA..',
                    },
                    {
                      'title': 'Produit',
                      'image_url':
                          'https://images.pexels.com/photos/2587370/pexels-photo-2587370.jpeg?_gl=1*asgoch*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk1NTI0MzMkbzU1JGcxJHQxNzY5NTUyNTA3JGo0OSRsMCRoMA..',
                    },
                    {
                      'title': 'Sac à dos',
                      'image_url':
                          'https://images.pexels.com/photos/27596308/pexels-photo-27596308.jpeg?_gl=1*deiple*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk1NTI0MzMkbzU1JGcxJHQxNzY5NTUzMTI1JGozNiRsMCRoMA..',
                    },
                    {
                      'title': 'Produit',
                      'image_url':
                          'https://images.pexels.com/photos/2688992/pexels-photo-2688992.jpeg?_gl=1*1b4lb4x*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk1NTI0MzMkbzU1JGcxJHQxNzY5NTUyNTM1JGoyMSRsMCRoMA..',
                    },
                    {
                      'title': 'Produit',
                      'image_url':
                          'https://images.pexels.com/photos/17545644/pexels-photo-17545644.jpeg?_gl=1*j0v2ol*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk1NTI0MzMkbzU1JGcxJHQxNzY5NTUyNTYxJGo2MCRsMCRoMA..',
                    },
                    {
                      'title': 'Produit',
                      'image_url':
                          'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg',
                    },
                    {
                      'title': 'Produit',
                      'image_url':
                          'https://images.pexels.com/photos/190819/pexels-photo-190819.jpeg',
                    },
                    {
                      'title': 'Produit',
                      'image_url':
                          'https://images.pexels.com/photos/15271715/pexels-photo-15271715.jpeg?_gl=1*1bjmyyf*_ga*MTc1NDgwNTg5Mi4xNzQ3NzcyOTEw*_ga_8JE65Q40S6*czE3Njk1NTI0MzMkbzU1JGcxJHQxNzY5NTUyNzM3JGoyOSRsMCRoMA..',
                    },

                    {
                      'title': 'Produit',
                      'image_url':
                          'https://images.pexels.com/photos/46710/pexels-photo-46710.jpeg',
                    },
                  ],
                  updateField: (field, value) => _updateField(field, value),
                  bio: bio,
                  onAvatarChanged: (XFile image) async {
                    final bytes = await image.readAsBytes();
                    _updateAvatarWeb(bytes, image.name);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
