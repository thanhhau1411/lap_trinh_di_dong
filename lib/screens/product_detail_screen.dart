import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchstore/Utils/favorite_manager.dart';
import 'package:watchstore/controllers/auth_controller.dart';
import 'package:watchstore/controllers/order_controller.dart';
import 'package:watchstore/models/data/product.dart';
import 'package:watchstore/models/data/thumbnail.dart';
import 'package:watchstore/models/data/product_attribute_value.dart';
import 'package:watchstore/models/data/watch_attribute.dart';
import 'package:watchstore/screens/checkout_screen.dart';
import 'package:watchstore/wiget/drawer_header.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final List<Thumbnail> thumbnails;
  final List<ProductAttributeValue> attributeValues;
  final List<WatchAttribute> attributes;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.thumbnails,
    required this.attributeValues,
    required this.attributes,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  void _loadFavoriteStatus() async {
    final fav = await FavoriteManager().isFavorite(widget.product);
    setState(() {
      isFavorite = fav;
    });
  }

  void _toggleFavorite() async {
    await FavoriteManager().toggleFavorite(widget.product);
    final fav = await FavoriteManager().isFavorite(widget.product);
    setState(() {
      isFavorite = fav;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(fav ? 'Đã thêm vào yêu thích' : 'Đã xóa khỏi yêu thích'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final mainAttributes =
    //     widget.attributes.map((attr) {
    //       final value = widget.attributeValues.firstWhere(
    //         (val) => val.attributeId == attr.attributeId,
    //         orElse: () {
    //           final safeProductId = widget.product.id ?? -1;
    //           final safeAttrId = attr.attributeId ?? -1;
    //           return ProductAttributeValue(
    //             productId: safeProductId,
    //             attributeId: safeAttrId,
    //             value: "N/A",
    //           );
    //         },
    //       );
    //       final attrName = attr.name ?? "Thuộc tính không rõ";
    //       return "$attrName: ${value.value}";
    //     }).toList();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          widget.product.name,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      endDrawer: Drawer(child: buildDrawerHeader(context, context.read<AuthController>().customerInfo!)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              widget.product.imageUrl,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.pink : Colors.grey,
                            size: 30,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  if (widget.thumbnails.isNotEmpty)
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.thumbnails.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.thumbnails[index].imageUrl,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 20),

                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.product.description,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "\$${widget.product.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // if (mainAttributes.isNotEmpty)
                  //   Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       const Text(
                  //         "Thông số kỹ thuật",
                  //         style: TextStyle(
                  //           fontSize: 18,
                  //           fontWeight: FontWeight.w600,
                  //         ),
                  //       ),
                  //       const SizedBox(height: 10),
                  //       ...mainAttributes.map(
                  //         (attr) => Padding(
                  //           padding: const EdgeInsets.only(bottom: 4.0),
                  //           child: Text(
                  //             "- $attr",
                  //             style: const TextStyle(fontSize: 14),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ChangeNotifierProvider(
                          create: (_) => OrderController(),
                          child: CheckoutScreen(
                            product: widget.product,
                            attributes: widget.attributes,
                          ),
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text("Mua ngay", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
