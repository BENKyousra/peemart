import 'package:flutter/material.dart';

class ProductImages extends StatefulWidget {
  final String mainImage;
  final List<String> images;

  const ProductImages({
    super.key,
    required this.mainImage,
    required this.images,
  });

  @override
  State<ProductImages> createState() => _ProductImagesState();
}

class _ProductImagesState extends State<ProductImages> {
  int selected = 0;
  late List<String> allImages;

  @override
  void initState() {
    super.initState();
    allImages = [widget.mainImage, ...widget.images];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 450,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: GestureDetector(
            onTap: () {
              _openImage(context, allImages[selected]);
            },
            child: Image.network(
              allImages[selected],
              width: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: allImages.length,
            itemBuilder:
                (_, i) => GestureDetector(
                  onTap: () => setState(() => selected = i),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            selected == i
                                ? const Color.fromARGB(255, 0, 169, 191)
                                : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.network(allImages[i], width: 70, fit: BoxFit.cover,alignment: Alignment.center,),
                  ),
                ),
          ),
        ),
      ],
    );
  }
}

void _openImage(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            // IMAGE ZOOMABLE
            InteractiveViewer(
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain, // garde dimension
                ),
              ),
            ),

            // BOUTON FERMER
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      );
    },
  );
}
