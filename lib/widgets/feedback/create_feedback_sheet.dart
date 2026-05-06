import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/feedback_service.dart';

class CreateFeedbackSheet extends StatefulWidget {
  const CreateFeedbackSheet({super.key});

  @override
  State<CreateFeedbackSheet> createState() => _CreateFeedbackSheetState();
}

class _CreateFeedbackSheetState extends State<CreateFeedbackSheet> {
  final supabase = Supabase.instance.client;
  final feedbackService = FeedbackService();
  final TextEditingController controller = TextEditingController();
  final ImagePicker picker = ImagePicker();

  List<Uint8List> images = [];
  bool loading = false;

  // 🔥 TAG SYSTEM
  List<Map<String, dynamic>> shops = [];

  // taggedShops = [{id, name}] des shops sélectionnés via suggestion
  List<Map<String, dynamic>> taggedShops = [];

  bool showSuggestions = false;
  int cursorPosition = 0;

  // =========================
  // INIT
  // =========================
  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      final text = controller.text;
      final selection = controller.selection.baseOffset;
      if (selection < 0) return;

      cursorPosition = selection;

      final lastAt = text.lastIndexOf('@', selection - 1);

      if (lastAt != -1) {
        final query = text.substring(lastAt + 1, selection);

        // Si la query est vide ou contient déjà un espace double → pas de suggestion
        if (query.isEmpty) {
          fetchShops('');
          setState(() => showSuggestions = true);
          return;
        }

        fetchShops(query);
        setState(() => showSuggestions = true);
      } else {
        setState(() => showSuggestions = false);
      }
    });
  }

  // =========================
  // FETCH SHOPS
  // =========================
  Future<void> fetchShops(String query) async {
    final res = await supabase
        .from('shops')
        .select('id, name, avatar')
        .ilike('name', '%$query%')
        .limit(5);

    setState(() {
      shops = List<Map<String, dynamic>>.from(res);
    });
  }

  // =========================
  // SELECT SHOP → insère @NomShop dans le texte
  // =========================
  void selectShop(Map<String, dynamic> shop) {
    final text = controller.text;
    final lastAt = text.lastIndexOf('@', cursorPosition - 1);

    final newText = text.substring(0, lastAt) +
        '@${shop['name']} ' +
        text.substring(cursorPosition);

    controller.text = newText;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: lastAt + (shop['name'] as String).length + 2),
    );

    // Enregistre le shop taggé (sans doublon)
    if (!taggedShops.any((s) => s['id'] == shop['id'])) {
      taggedShops.add({'id': shop['id'], 'name': shop['name']});
    }

    setState(() => showSuggestions = false);
  }

  // =========================
  // PICK IMAGES
  // =========================
  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();
    final List<Uint8List> temp = [];
    for (final img in picked) {
      temp.add(await img.readAsBytes());
    }
    setState(() => images.addAll(temp));
  }

  // =========================
  // PUBLISH
  // =========================
  Future<void> publish() async {
    final content = controller.text.trim();
    if (content.isEmpty && images.isEmpty) return;

    setState(() => loading = true);

    // Garde seulement les shops encore mentionnés dans le texte
    final activeShops = taggedShops
        .where((s) => content.contains('@${s['name']}'))
        .toList();

    await feedbackService.createFullFeedback(
      content: content,
      images: images,
      taggedShops: activeShops,
    );

    if (mounted) {
      setState(() => loading = false);
      Navigator.pop(context);
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HANDLE
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 15),

          // TEXT FIELD
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Écris ton feedback... (@shop)",
                border: InputBorder.none,
              ),
            ),
          ),

          // 🔥 SUGGESTIONS
          if (showSuggestions && shops.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: shops.length,
                itemBuilder: (context, i) {
                  final shop = shops[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: shop['avatar'] != null
                          ? NetworkImage(shop['avatar'])
                          : null,
                      child: shop['avatar'] == null
                          ? const Icon(Icons.store)
                          : null,
                    ),
                    title: Text(shop['name']),
                    onTap: () => selectShop(shop),
                  );
                },
              ),
            ),

          const SizedBox(height: 15),

          // IMAGE GRID
          if (images.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, i) {
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: MemoryImage(images[i]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 5,
                        child: GestureDetector(
                          onTap: () => setState(() => images.removeAt(i)),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

          const SizedBox(height: 15),

          // ACTIONS
          Row(
            children: [
              IconButton(
                onPressed: pickImages,
                icon: const Icon(Icons.image),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 2, 105),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: loading ? null : publish,
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        "Publier",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}