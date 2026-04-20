import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditImagesSheet extends StatefulWidget {
  final String feedbackId;
  final List images;
  final VoidCallback onUpdated;

  const EditImagesSheet({
    super.key,
    required this.feedbackId,
    required this.images,
    required this.onUpdated,
  });

  @override
  State<EditImagesSheet> createState() => _EditImagesSheetState();
}

class _EditImagesSheetState extends State<EditImagesSheet> {
  final supabase = Supabase.instance.client;
  final picker = ImagePicker();

  List existingImages = [];
  List<Uint8List> newImages = [];

  @override
  void initState() {
    super.initState();
    existingImages = List.from(widget.images);
  }

  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();

    for (var img in picked) {
      newImages.add(await img.readAsBytes());
    }

    setState(() {});
  }

  Future<String> upload(Uint8List bytes) async {
    final name = DateTime.now().millisecondsSinceEpoch.toString();

    await supabase.storage
        .from('feedback-images')
        .uploadBinary(name, bytes);

    return supabase.storage.from('feedback-images').getPublicUrl(name);
  }

  Future<void> save() async {
    // 🔥 DELETE REMOVED IMAGES
    await supabase
        .from('feedback_images')
        .delete()
        .eq('feedback_id', widget.feedbackId);

    int index = 0;

    // 🔁 REINSERT EXISTING
    for (var img in existingImages) {
      await supabase.from('feedback_images').insert({
        'feedback_id': widget.feedbackId,
        'image_url': img['image_url'],
        'display_order': index++,
      });
    }

    // 🆕 ADD NEW
    for (var img in newImages) {
      final url = await upload(img);

      await supabase.from('feedback_images').insert({
        'feedback_id': widget.feedbackId,
        'image_url': url,
        'display_order': index++,
      });
    }

    widget.onUpdated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Text("Modifier les images",
              style: TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          // EXISTING
          Wrap(
            children: existingImages.map((img) {
              return Stack(
                children: [
                  Image.network(img['image_url'], width: 80),
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => existingImages.remove(img));
                      },
                      child: const Icon(Icons.close, color: Colors.red),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          // NEW
          Wrap(
            children: newImages.map((img) {
              return Image.memory(img, width: 80);
            }).toList(),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: pickImages,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: save,
                child: const Text("Enregistrer"),
              ),
            ],
          )
        ],
      ),
    );
  }
}