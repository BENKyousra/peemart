import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'editable_field.dart';

class ProfileInfo extends StatefulWidget {
  final String avatarUrl;
  final String username;
  final String email;
  final String bio;
  final bool isSeller;
  final List<dynamic> favorites;
  final Function(String field, dynamic value) updateField;

  const ProfileInfo({
    super.key,
    required this.avatarUrl,
    required this.username,
    required this.email,
    required this.bio,
    required this.isSeller,
    required this.favorites,
    required this.updateField,
  });

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  String? localAvatarPath;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        localAvatarPath = image.path;
      });
      // Ici tu peux appeler widget.updateField('avatar_url', ...) plus tard pour backend
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            elevation: 7,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== PROFIL =====
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: localAvatarPath != null
                                ? FileImage(File(localAvatarPath!)) as ImageProvider
                                : NetworkImage(widget.avatarUrl),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 0, 169, 191),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.username,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.email,
                              style: const TextStyle(color: Colors.grey),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ===== CHAMPS MODIFICATION =====
                  EditableField(
                    label: 'Nom',
                    initialValue: widget.username,
                    onSave: (value) => widget.updateField('username', value),
                  ),
                  const SizedBox(height: 8),
                  EditableField(
                    label: 'Email',
                    initialValue: widget.email,
                    onSave: (value) => widget.updateField('email', value),
                  ),
                  const SizedBox(height: 8),
                  EditableField(
                    label: 'Bio',
                    initialValue: widget.bio,
                    onSave: (value) => widget.updateField('bio', value),
                  ),

                  const SizedBox(height: 24),

                  // ===== PRODUITS FAVORIS =====
                  Text(
                    'Produits favoris',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  widget.favorites.isEmpty
                      ? const Center(child: Text('Aucun favori'))
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: widget.favorites.length,
                          itemBuilder: (context, index) {
                            final item = widget.favorites[index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: item['image_url'] != null
                                          ? Image.network(
                                              item['image_url']!,
                                              fit: BoxFit.cover,
                                            )
                                          : const Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                              ),
                                            ),
                                    ),
                                    if (item['title'] != null)
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          color: Colors.black.withOpacity(0.5),
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            item['title']!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                            softWrap: true,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
