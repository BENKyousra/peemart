import 'package:flutter/material.dart';

class ImageViewer {
  static void open(BuildContext context, List images, int index) {
    PageController controller = PageController(initialPage: index);

    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: PageView.builder(
            controller: controller,
            itemCount: images.length,
            itemBuilder: (context, i) {
              return InteractiveViewer(
                child: Center(
                  child: Image.network(images[i]['image_url']),
                ),
              );
            },
          ),
        );
      },
    );
  }
}