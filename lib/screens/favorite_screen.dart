import 'package:flutter/material.dart';
import 'package:watchstore/Utils/favorite_manager.dart';
import 'package:watchstore/models/data/product.dart';
import 'package:watchstore/screens/product_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final favoriteManager = FavoriteManager();

  @override
  void initState() {
    super.initState();
    // Nếu cần load dữ liệu ngoài (ví dụ: từ shared_preferences) thì gọi tại đây
    // nhưng đảm bảo favoriteManager.loadFavorites() đã được gọi trước ở main hoặc Home
  }

  @override
  Widget build(BuildContext context) {
    final favorites = favoriteManager.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm yêu thích'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Text(
                'Bạn chưa có sản phẩm yêu thích nào.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: favorites.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final product = favorites[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product,attributeValues: [], attributes: [], thumbnails: [],),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Expanded(
                          //   child: ClipRRect(
                          //     borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          //     child: Image.network(
                          //       product.thumbnail?.image ?? '',
                          //       fit: BoxFit.cover,
                          //     ),
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'brand a',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${product.price.toStringAsFixed(0)} đ',
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
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
    );
  }
}
