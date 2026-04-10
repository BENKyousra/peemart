import 'package:flutter/material.dart';
import '../../widgets/profile/profile_settings.dart';
import '../../widgets/profile/profile_info.dart';
import 'package:image_picker/image_picker.dart';

class ProfileLayout extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Colonne paramètres =====
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.topLeft,
              child: ProfileSettings(
                isSeller: isSeller,
                updateSeller: updateSeller,
                logout: logout,
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
                favorites: const [],
                bio: bio,
                updateField: updateField,
                onAvatarChanged: onAvatarChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}