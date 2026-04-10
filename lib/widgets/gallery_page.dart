import 'package:flutter/material.dart';

class GalleryPage extends StatefulWidget {
  final List images;
  final int index;

  const GalleryPage({super.key, required this.images, required this.index});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: controller,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            // 🔥 يسمح بالتكبير/التصغير
            minScale: 0.8,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                getImageUrl(widget.images[index]['image_url']),
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }

  String getImageUrl(dynamic value) {
    if (value == null) return '';

    if (value is String) return value;

    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }

    return '';
  }
}
