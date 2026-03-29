import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  // 🔹 GET PROFILE
  Future<ProfileModel?> getProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final data =
        await supabase.from('users').select().eq('id', user.id).single();

    return ProfileModel.fromMap(data);
  }

  // 🔹 UPDATE FIELD
  Future<void> updateField(String field, dynamic value) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('users').update({field: value}).eq('id', user.id);
  }

  // 🔹 UPLOAD AVATAR (Supabase Storage)
  Future<String?> uploadAvatar(Uint8List bytes) async {
  final user = supabase.auth.currentUser;
  if (user == null) return null;

  final path = '${user.id}/avatar.png';
  final bucket = supabase.storage.from('avatars');

  try {
    // 🔥 1. Supprimer ancien fichier (optionnel mais propre)
    await bucket.remove([path]);

    // 🔥 2. Upload nouveau
    await bucket.uploadBinary(
      path,
      bytes,
    );

    // 🔥 3. Récupérer URL
    final url = bucket.getPublicUrl(path);

    // 🔥 4. Ajouter cache buster (important)
    final finalUrl =
        "$url?t=${DateTime.now().millisecondsSinceEpoch}";

    // 🔥 5. UPDATE DATABASE (TRÈS IMPORTANT)
    await supabase
        .from('users')
        .update({'avatar_url': finalUrl})
        .eq('id', user.id);

    return finalUrl;
  } catch (e) {
    print("❌ Upload error: $e");
    return null;
  }
}

  // 🔹 LOGOUT
  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
