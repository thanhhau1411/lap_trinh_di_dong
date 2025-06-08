import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchstore/controllers/auth_controller.dart';
import 'package:watchstore/controllers/brand_controller.dart';
import 'package:watchstore/controllers/customer_controller.dart';
import 'package:watchstore/controllers/product_controller.dart';
import 'package:watchstore/models/data/brand.dart';
import 'package:watchstore/models/data/product.dart';
import 'package:watchstore/models/data/product_attribute_value.dart';
import 'package:watchstore/models/data/thumbnail.dart';
import 'package:watchstore/models/data/watch_attribute.dart';
import 'package:watchstore/screens/product_detail_screen.dart';
import 'package:watchstore/screens/search_screen.dart';
import 'package:watchstore/wiget/drawer_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _brandController = BrandController();
  late ProductController _productController;
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productController = Provider.of<ProductController>(context);
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
    // Provider.of<CustomerController>(context);
    final authController = context.watch<AuthController>();
    final filteredProducts =
        allProducts
            .where((product) => product.brandId == selectedBrandId)
            .toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      drawer: Drawer(
        child: buildDrawerHeader(context, authController.customerInfo),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.search),
                    color: Colors.grey,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SearchScreen()),
                      );
                    },
                  ),
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
                    childAspectRatio: 0.75,
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
                      child: IntrinsicHeight(
                        child: ProductCard(product: product),
                      ),
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
          // Image - Fixed height
          Container(
            height: 100, // Giảm chiều cao image
            width: double.infinity,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              image: DecorationImage(
                image:
                    (product.imageUrl.startsWith('http'))
                        ? NetworkImage(product.imageUrl)
                        : FileImage(File(product.imageUrl)),
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Product info section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14, // Giảm font size
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Description
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12, // Giảm font size
                      height: 1.3,
                    ),
                  ),

                  const Spacer(),

                  // Price and Button row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Price
                      Text(
                        '\$${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),

                      // Button
                      SizedBox(
                        height: 28,
                        width: 65,
                        child: ElevatedButton(
                          onPressed: () async {
                            final productId = product.id;
                            if (productId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("product id null")),
                              );
                              return;
                            }
                            final thumbnails = await _productController
                                .getThumbnail(product.id!);
                            final watchAttribute =
                                await _productController.getWatchAttribute(
                                  productId,
                                ) ??
                                [];
                            if (watchAttribute.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("watchAttribute is empty"),
                                ),
                              );
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
                            if (attributeValues.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("attributeValues is empty"),
                                ),
                              );
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProductDetailScreen(
                                      product: product,
                                      thumbnails: thumbnails,
                                      attributeValues:
                                          attributeValues
                                              .whereType<
                                                ProductAttributeValue
                                              >()
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
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: EdgeInsets.zero,
                            elevation: 2,
                          ),
                          child: const Text(
                            'Chi tiết',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8), // Bottom spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
