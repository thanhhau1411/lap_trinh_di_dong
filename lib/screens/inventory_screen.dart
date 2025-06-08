import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/product_controller.dart';
import '../models/data/product.dart';
import 'product_edit_screen.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _selectedFilter = 'Tất cả';
  final Color primary = const Color(0xFF0078D4);

  bool _isLoading = true; // trạng thái loading

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final productController = Provider.of<ProductController>(
      context,
      listen: false,
    );
    await productController.loadProductsFromDb();
    setState(() {
      _isLoading = false; // load xong thì tắt loading
    });
  }

  @override
  Widget build(BuildContext context) {
    final productController = Provider.of<ProductController>(context);
    final allProducts = productController.products;
    final lowStockProducts = productController.lowStockProducts;

    final filteredProducts =
        _selectedFilter == 'Tất cả'
            ? allProducts
            : _selectedFilter == 'Gần hết hàng'
            ? allProducts.where((p) => p.quantity <= 3).toList()
            : allProducts.where((p) => p.quantity > 3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý tồn kho',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primary,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  if (lowStockProducts.isNotEmpty)
                    Container(
                      color: Colors.redAccent,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Cảnh báo: ${lowStockProducts.length} sản phẩm gần hết hàng!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFilterChip('Tất cả', _selectedFilter == 'Tất cả'),
                        _buildFilterChip(
                          'Gần hết hàng',
                          _selectedFilter == 'Gần hết hàng',
                        ),
                        _buildFilterChip(
                          'Còn hàng',
                          _selectedFilter == 'Còn hàng',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        filteredProducts.isEmpty
                            ? const Center(
                              child: Text(
                                'Không có sản phẩm nào',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: CircleAvatar(
                                      radius: 24,
                                      backgroundColor:
                                          product.quantity <= 3
                                              ? Colors.redAccent.withOpacity(
                                                0.1,
                                              )
                                              : primary.withOpacity(0.1),
                                      backgroundImage:
                                          (product.imageUrl != null &&
                                                  product.imageUrl.isNotEmpty)
                                              ? AssetImage(product.imageUrl)
                                              : null,
                                      child:
                                          (product.imageUrl == null ||
                                                  product.imageUrl.isEmpty)
                                              ? Icon(
                                                product.quantity <= 3
                                                    ? Icons
                                                        .warning_amber_rounded
                                                    : Icons.inventory_2,
                                                color:
                                                    product.quantity <= 3
                                                        ? Colors.redAccent
                                                        : primary,
                                              )
                                              : null,
                                    ),
                                    title: Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Tồn kho: ${product.quantity}',
                                      style: TextStyle(
                                        color:
                                            product.quantity <= 3
                                                ? Colors.redAccent
                                                : Colors.grey[600],
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.edit, color: primary),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (ctx) => ProductEditScreen(
                                                  product: product,
                                                ),
                                          ),
                                        );
                                        if (result != null &&
                                            result is Product) {
                                          await productController.updateProduct(
                                            result,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newProduct = await Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const ProductEditScreen()),
          );
          if (newProduct != null && newProduct is Product) {
            await productController.addProduct(newProduct);
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: primary,
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedColor: primary,
      backgroundColor: Colors.grey[200],
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
