import 'package:flutter/material.dart';
import 'package:watchstore/models/data/product.dart';
import 'package:watchstore/models/data/thumbnail.dart';
import 'package:watchstore/models/data/product_attribute_value.dart';
import 'package:watchstore/models/data/watch_attribute.dart';

class ProductDetailScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final mainAttributes = attributes.map((attr) {
      final value = attributeValues.firstWhere(
        (val) => val.attributeId == attr.attributeId,
        orElse: () => ProductAttributeValue(
          productId: product.id!,
          attributeId: attr.attributeId!,
          value: "N/A",
        ),
      );
      return "${attr.name}: ${value.value}";
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name, style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.red.shade400,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main image
            Center(
              child: Image.network(
                product.imageUrl,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 10),

            // Thumbnail list
            if (thumbnails.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: thumbnails.length,
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
                          thumbnails[index].imageUrl,
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
              product.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              product.description,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),

            const SizedBox(height: 16),

            Text(
              "\$${product.price.toStringAsFixed(2)}",
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
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Mua ngay",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
