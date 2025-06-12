import 'package:flutter/material.dart';
import 'package:watchstore/controllers/product_controller.dart';
import 'package:watchstore/models/data/database_helper.dart';
import 'package:watchstore/models/data/product.dart';
import 'package:watchstore/screens/confirm_receipt.dart';

class StockInScreen extends StatefulWidget {
  final List<Product> products;

  StockInScreen({required this.products});

  @override
  _StockInScreenState createState() => _StockInScreenState();
}

class _StockInScreenState extends State<StockInScreen> {
  List<Product> products = [];
  Map<int, int> quantities = {};
  Map<int, double> importPrices = {};
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    loadProducts();
  }

  List<String> brandNames = [];

  Future<void> loadProducts() async {
    final results = await _databaseHelper.getProductsWithBrand();
    setState(() {
      products = results.map((map) => Product.fromMap(map)).toList();
      brandNames = results.map((map) => map['brandName'] as String).toList();
    });
  }

  Future<void> _loadProducts() async {
    final data = await getProducts(); // Lấy dữ liệu sản phẩm từ DB
    setState(() {
      products = data;
      for (var p in products) {
        quantities[p.id!] = 0;
        importPrices[p.id!] = p.price;
      }
    });
  }

  void _goToConfirm() {
    final selectedItems =
        products.where((p) => quantities[p.id!]! > 0).toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập số lượng cho ít nhất một sản phẩm'),
        ),
      );
      return;
    }

    final itemsWithDetails =
        selectedItems.map((product) {
          return {
            'product': product,
            'quantity': quantities[product.id!]!,
            'importPrice': importPrices[product.id!]!,
          };
        }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                ConfirmStockInScreen(itemsWithDetails: itemsWithDetails),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Tạo phiếu nhập')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Tạo phiếu nhập')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/products/${product.imageUrl}',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    product.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Thương hiệu: ${brandNames[index]}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepOrangeAccent.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: quantities[product.id!].toString(),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Số lượng nhập',
                          ),
                          onChanged: (val) {
                            setState(() {
                              quantities[product.id!] = int.tryParse(val) ?? 0;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: importPrices[product.id!]
                              ?.toStringAsFixed(0),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Giá nhập'),
                          onChanged: (val) {
                            setState(() {
                              importPrices[product.id!] =
                                  double.tryParse(val) ?? product.price;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToConfirm,
        label: Text('Xác nhận'),
        icon: Icon(Icons.arrow_forward),
      ),
    );
  }
}
