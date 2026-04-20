import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateFeedbackSheet extends StatefulWidget {
  const CreateFeedbackSheet({super.key});

  @override
  State<CreateFeedbackSheet> createState() => _CreateFeedbackSheetState();
}

class _CreateFeedbackSheetState extends State<CreateFeedbackSheet> {
  final supabase = Supabase.instance.client;
  final TextEditingController controller = TextEditingController();
  final ImagePicker picker = ImagePicker();

  List<Uint8List> images = []; // ✅ UNE SEULE LISTE

  bool loading = false;

  // =========================
  // PICK MULTI IMAGES (ONLY)
  // =========================
  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();

    List<Uint8List> temp = [];

    for (var img in picked) {
      temp.add(await img.readAsBytes());
    }

    setState(() {
      images.addAll(temp);
    });
  }

  // =========================
  // UPLOAD IMAGE
  // =========================
  Future<String> uploadImage(Uint8List bytes) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage
        .from('feedback-images')
        .uploadBinary(fileName, bytes);

    return supabase.storage
        .from('feedback-images')
        .getPublicUrl(fileName);
  }

  // =========================
  // PUBLISH
  // =========================
  Future<void> publish() async {
    if (controller.text.trim().isEmpty && images.isEmpty) return;

    setState(() => loading = true);

    final user = supabase.auth.currentUser;

    final feedback = await supabase.from('feedbacks').insert({
      'user_id': user!.id,
      'content': controller.text.trim(),
    }).select().single();

    final id = feedback['id'];

    // upload all images
    for (int i = 0; i < images.length; i++) {
      final url = await uploadImage(images[i]);

      await supabase.from('feedback_images').insert({
        'feedback_id': id,
        'image_url': url,
        'display_order': i,
      });
    }

    setState(() => loading = false);
    Navigator.pop(context);
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

          // TEXT
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
                hintText: "Écris ton feedback...",
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 15),

          // 🖼 IMAGE GRID (MODERNE)
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

                      // ❌ REMOVE IMAGE
                      Positioned(
                        right: 10,
                        top: 5,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              images.removeAt(i);
                            });
                          },
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
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

              // 📷 PICK IMAGES
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

              // 🚀 POST
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 2, 105),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
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