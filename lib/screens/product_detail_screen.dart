import 'package:flutter/material.dart';
import 'package:watchstore/Utils/favorite_manager.dart';
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
    isFavorite = FavoriteManager().isFavorite(widget.product);
  }

  @override
  Widget build(BuildContext context) {
    final mainAttributes =
        widget.attributes.map((attr) {
          final value = widget.attributeValues.firstWhere(
            (val) => val.attributeId == attr.attributeId,
            orElse:
                () => ProductAttributeValue(
                  productId: widget.product.id!,
                  attributeId: attr.attributeId!,
                  value: "N/A",
                ),
          );
          return "${attr.name}: ${value.value}";
        }).toList();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.product.name, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            icon: Icon(Icons.menu),
          ),
        ],
      ),
      endDrawer: Drawer(child: buildDrawerHeader(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main image with favorite button
            Stack(
              children: [
                Center(
                  child: Image.network(
                    widget.product.imageUrl,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.pink : Colors.grey,
                      size: 28,
                    ),
                    onPressed: () async {
                      await FavoriteManager().toggleFavorite(widget.product);
                      setState(() {
                        isFavorite = FavoriteManager().isFavorite(
                          widget.product,
                        );
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite
                                ? 'Đã thêm vào yêu thích'
                                : 'Đã xóa khỏi yêu thích',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Thumbnail list
            if (widget.thumbnails.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.thumbnails.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
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

            const SizedBox(height: 16),

            Text(
              widget.product.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.product.description,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),

            const SizedBox(height: 16),

            Text(
              "\$${widget.product.price.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 16),

            // Attributes
            if (mainAttributes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Thông số kỹ thuật",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ...mainAttributes.map((attr) => Text("- $attr")),
                ],
              ),

            const SizedBox(height: 24),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Xử lý mua hàng
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => CheckoutScreen(
                            product: widget.product,
                            attributes: [
                              WatchAttribute(
                                attributeId: 1,
                                name: 'bandLength',
                                dataType: 'double',
                                quantity: 50,
                              ),
                              WatchAttribute(
                                attributeId: 2,
                                name: 'thickness',
                                dataType: 'double',
                                quantity: 50,
                              ),
                            ],
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Mua ngay", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
