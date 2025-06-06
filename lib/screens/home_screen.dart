import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchstore/controllers/auth_controller.dart';
import 'package:watchstore/controllers/brand_controller.dart';
import 'package:watchstore/controllers/product_controller.dart';
import 'package:watchstore/models/data/brand.dart';
import 'package:watchstore/models/data/product.dart';
import 'package:watchstore/models/data/product_attribute_value.dart';
import 'package:watchstore/models/data/thumbnail.dart';
import 'package:watchstore/models/data/watch_attribute.dart';
import 'package:watchstore/screens/product_detail_screen.dart';
import 'package:watchstore/wiget/drawer_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _brandController = BrandController();
  final _productController = ProductController();
  int selectedBrandId = 1;

  List<Brand> brands = [];

  List<Product> allProducts = [];

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
    loadBrands();
    loadProducts();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadBrands() async {
    final loadedBrands = await _brandController.loadAll();
    setState(() {
      brands = loadedBrands;
    });
  }

  Future<void> loadProducts() async {
    final loadedProducts = await _productController.getAll();
    setState(() {
      allProducts = loadedProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts =
        allProducts
            .where((product) => product.brandId == selectedBrandId)
            .toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      drawer: Drawer(child: buildDrawerHeader(context, context.read<AuthController>().customerInfo)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          icon: IconButton(
                            icon: Icon(Icons.search),
                            color: Colors.grey,
                            onPressed: () {},
                          ),
                          hintText: "Find Your Watch",
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // const Icon(Icons.notifications_none),
                ],
              ),
            ),

            // Title
            // const Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //   child: Text(
            //     "Find Your Suitable Watch Now",
            //     style: TextStyle(
            //       fontSize: 22,
            //       fontWeight: FontWeight.bold,
            //       height: 1.4,
            //     ),
            //   ),
            // ),

            // Brand tabs
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: brands.length,
                itemBuilder: (context, index) {
                  final brand = brands[index];
                  final isSelected = brand.id == selectedBrandId;
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        selectedBrandId = brand.id!;
                        _animationController.reset();
                        _animationController.forward();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected ? Colors.red : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          brand.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.red : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Product Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: filteredProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.68,
                  ),
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          0.1 * index,
                          1.0,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: ProductCard(product: product),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  late ProductController _productController;
  ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    _productController = context.watch<ProductController>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade200.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 120,
            width: double.infinity,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              image: DecorationImage(
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                height: 1.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              product.description,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ElevatedButton(
                      onPressed: () async {
                        final productId = product.id;
                        if (productId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("product id null")));
                          return;
                        }

                        final watchAttribute =
                            await _productController.getWatchAttribute(
                              productId,
                            ) ??
                            [];
                        if(watchAttribute.isEmpty) {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("watchAttribute is empty")));
                        }
                        final futures =
                            watchAttribute.map((attr) {
                              final attrId = attr.attributeId;
                              if (attrId == null) return Future.value(null);
                              return _productController.getAttributeValue(
                                productId,
                                attrId,
                              );
                            }).toList();

                        final attributeValues = await Future.wait(futures);
                         if(attributeValues.isEmpty) {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("attributeValues is empty")));
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductDetailScreen(
                                  product: product,
                                  thumbnails: [
                                    Thumbnail(
                                      id: 1,
                                      productId: productId,
                                      imageUrl: 'assets/images/mock1.jpg',
                                    ),
                                    Thumbnail(
                                      id: 2,
                                      productId: productId,
                                      imageUrl: 'assets/images/mock2.jpg',
                                    ),
                                  ],
                                  attributeValues:
                                      attributeValues
                                          .whereType<ProductAttributeValue>()
                                          .toList(),
                                  attributes: watchAttribute,
                                ),
                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Xem chi tiết',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
