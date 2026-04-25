import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'editable_field.dart';
import '../../models/product_model.dart';
import '../../pages/products/product_detail_page.dart';
import '../../widgets/product/product_card.dart';

class ProfileInfo extends StatefulWidget {
  final String avatarUrl;
  final String username;
  final String email;
  final String bio;
  final bool isSeller;
  final List<ProductModel> favorites;
  final Function(String field, dynamic value) updateField;
  final Future<void> Function(XFile image) onAvatarChanged;

  const ProfileInfo({
    super.key,
    required this.avatarUrl,
    required this.username,
    required this.email,
    required this.bio,
    required this.isSeller,
    required this.favorites,
    required this.updateField,
    required this.onAvatarChanged,
  });

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      await widget.onAvatarChanged(image);

      setState(() {
        // forcer rebuild avec nouvelle URL
      });
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
                            key: ValueKey(
                              widget.avatarUrl,
                            ), // 🔥 force rebuild image
                            radius: 50,
                            backgroundImage: NetworkImage(widget.avatarUrl),
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
    ? const Center(child: Text("Aucun produit en favori"))
    : GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.65,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: widget.favorites.length,
        itemBuilder: (context, index) {
          final product = widget.favorites[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: product),
                ),
              );
            },
            child: ProductCard(
              product: product,
              reviewCount: product.reviewCount,
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
