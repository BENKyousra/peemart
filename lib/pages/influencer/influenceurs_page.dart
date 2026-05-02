import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/product_model.dart';
import 'package:peemart/pages/add_post_page.dart';
import 'comment_page.dart';
import 'influencer_page.dart';
import 'package:peemart/pages/products/product_detail_page.dart';
import 'package:peemart/services/post_service.dart';
import '../../services/influencer/product_service.dart';
import 'package:peemart/pages/gallery_page.dart';
import '../../widgets/navbar.dart';

class InfluenceursPage extends StatefulWidget {
  const InfluenceursPage({super.key});

  @override
  State<InfluenceursPage> createState() => _InfluenceursPageState();
}

class _InfluenceursPageState extends State<InfluenceursPage> {
  final ProductService productService = ProductService();

  List<Map<String, dynamic>> posts = [];
  Map<String, int> likesCount = {};
  Map<String, bool> likedStatus = {};

  bool isLoading = true;
  bool isInfluencer = false;

   final ScrollController _scrollController = ScrollController();
  double scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    initPage();
     _scrollController.addListener(() {
      setState(() {
        scrollOffset = _scrollController.offset;
      });
    });
  }

  Future<void> initPage() async {
    await Future.wait([checkInfluencer(), loadData()]);
  }

  Future<void> checkInfluencer() async {
    final influencer = await PostService().getMyInfluencer();
    setState(() => isInfluencer = influencer != null);
  }

  Future<void> loadData() async {
    final data = await PostService().getPosts();

    // 🔥 اعرض المنشورات فوراً بدون انتظار الـ likes
    setState(() {
      posts = data;
      isLoading = false; // ✅ الصفحة تظهر هنا
    });

    // 🔥 حمّل الـ likes في الخلفية
    Map<String, int> tempLikes = {};
    Map<String, bool> tempLiked = {};

    await Future.wait(
      data.map((post) async {
        final productId = post['products']['id'];
        final count = await productService.getLikesCount(productId);
        final liked = await productService.isLiked(productId);
        tempLikes[productId] = count;
        tempLiked[productId] = liked;
      }),
    );

    // ✅ تحديث الـ likes بعد ما تجهز
    if (mounted) {
      setState(() {
        likesCount = tempLikes;
        likedStatus = tempLiked;
      });
    }

     _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      floatingActionButton:
          isInfluencer
              ? FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddPostPage()),
                  );
                  loadData();
                },
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,

      body: Column(
        children: [
          NavBar(scrollOffset: scrollOffset),

          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final influencer = post['influencers'];
                        final product = post['products'];
                        final postImages = List<Map<String, dynamic>>.from(
                          post['post_images'] ?? [],
                        );
                        final productImages = List<Map<String, dynamic>>.from(
                          product['product_images'] ?? [],
                        );
                        final fallbackImage = product['image'];

                        // 🔥 دمج الاثنين دائماً
                        final images = [...postImages, ...productImages];

                        // إذا لم يوجد شيء، استخدم الصورة الرئيسية
                        final finalImages =
                            images.isNotEmpty
                                ? images
                                : (fallbackImage != null
                                    ? [
                                      {'image_url': fallbackImage},
                                    ]
                                    : []);

                        return Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 700),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// 🔹 HEADER
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      /// 🔥 clickable (image + name)
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => InfluencerPage(
                                                    influencerId:
                                                        influencer['id'],
                                                  ),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 25,
                                              backgroundImage:
                                                  influencer['avatar'] != null
                                                      ? NetworkImage(
                                                        influencer['avatar'],
                                                      )
                                                      : null,
                                              child:
                                                  influencer['avatar'] == null
                                                      ? const Icon(
                                                        Icons
                                                            .people_outline_sharp,
                                                      )
                                                      : null,
                                            ),

                                            const SizedBox(width: 10),

                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      influencer['name'] ?? '',
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    if (influencer['is_verified'] ==
                                                        true)
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                              left: 4,
                                                            ),
                                                        child: Icon(
                                                          Icons.verified,
                                                          color: Colors.blue,
                                                          size: 14,
                                                        ),
                                                      ),
                                                  ],
                                                ),

                                                // 🔥 عدد المشتركين تحت الاسم
                                                if ((influencer['followers_count'] ??
                                                        0) >
                                                    0)
                                                  Text(
                                                    'Followers ${_formatFollowers(influencer['followers_count'])}',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(162, 0, 169, 191),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      const Spacer(),

                                      /// 🔹 discount code (يبقى كما هو)
                                      GestureDetector(
                                        onTap: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text:
                                                  influencer['discount_code'] ??
                                                  '',
                                            ),
                                          );

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("Code copié ✅"),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                influencer['discount_code'] ??
                                                    "",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(Icons.copy, size: 14),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// 🔹 IMAGE
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: buildImages(finalImages),
                                ),

                                /// 🔹 ACTIONS
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          likedStatus[product['id']] == true
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Color.fromARGB(
                                            255,
                                            255,
                                            10,
                                            88,
                                          ),
                                        ),
                                        onPressed: () async {
                                          setState(() {
                                            likedStatus[product['id']] =
                                                !likedStatus[product['id']]!;
                                            likesCount[product['id']] =
                                                likedStatus[product['id']]!
                                                    ? likesCount[product['id']]! +
                                                        1
                                                    : likesCount[product['id']]! -
                                                        1;
                                          });

                                          await productService.toggleLike(
                                            product['id'],
                                          );
                                        },
                                      ),

                                      Text(
                                        "${likesCount[product['id']] ?? 0}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      IconButton(
                                        icon: const Icon(
                                          Icons.chat_bubble_outline,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => CommentsPage(
                                                    productId: product['id'],
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                /// 🔹 TEXT
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['title'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        post['description'] ?? "",
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Row(
                                        children: [
                                          Text(
                                            "${product['price']} DA",
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                255,
                                                0,
                                                169,
                                                191,
                                              ),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          const Spacer(),

                                          TextButton(
                                            child: const Text(
                                              "Voir plus",
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            onPressed: () {
                                              final fixedProduct =
                                                  Map<String, dynamic>.from(
                                                    product,
                                                  );

                                              final shopData =
                                                  fixedProduct['shops'];

                                              if (shopData is List &&
                                                  shopData.isNotEmpty) {
                                                fixedProduct['shops'] =
                                                    shopData[0];
                                              }

                                              final productModel =
                                                  ProductModel.fromMap(
                                                    fixedProduct,
                                                  );

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) => ProductDetailPage(
                                                        product: productModel,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  void openGallery(List images, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GalleryPage(images: images, index: index),
      ),
    );
  }

  Widget buildPostImage(String url) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
      ),
    );
  }

  Widget buildImages(List images) {
    if (images.isEmpty) return const SizedBox();

    if (images.length == 1) {
      return GestureDetector(
        onTap: () => openGallery(images, 0),
        child: buildPostImage(getImageUrl(images[0]['image_url'])),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length > 4 ? 4 : images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 16 / 9,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => openGallery(images, index),
          child: Stack(
            children: [
              buildPostImage(getImageUrl(images[index]['image_url'])),

              if (index == 3 && images.length > 4)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Text(
                      "+${images.length - 4}",
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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

  String _formatFollowers(dynamic count) {
    if (count == null) return '';
    final n = (count as num).toInt();
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M 👥';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K 👥';
    return '$n 👥';
  }
}
