import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/data/product.dart';

class ProductController extends ChangeNotifier {
  Database? _db;
  final List<Product> _products = [];

  List<Product> get products => List.unmodifiable(_products);

  Future<void> initDb() async {
    try {
      final path = join(await getDatabasesPath(), 'inventory.db');
      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE products (
              id TEXT PRIMARY KEY,
              name TEXT,
              description TEXT,
              price REAL,
              quantity INTEGER,
              imageUrl TEXT
            )
          ''');

          // Thêm sản phẩm mẫu
          await db.insert('products', {
            'id': 'SP001',
            'name': 'Rolex Submariner',
            'description': 'Luxury dive watch',
            'price': 15000,
            'quantity': 10,
            'imageUrl': 'assets/images/product1_1.png',
          });
          await db.insert('products', {
            'id': 'SP002',
            'name': 'Omega Seamaster',
            'description': 'Classic diving watch',
            'price': 12000,
            'quantity': 5,
            'imageUrl': 'assets/images/product1_2.png',
          });
          await db.insert('products', {
            'id': 'SP003',
            'name': 'Casio G-Shock',
            'description': 'Durable sport watch',
            'price': 200,
            'quantity': 20,
            'imageUrl': 'assets/images/product1_3.png',
          });
        },
      );

      await loadProductsFromDb();
    } catch (e) {
      debugPrint('Error initializing database: $e');
    }
  }

  Future<void> loadProductsFromDb() async {
    if (_db == null) return;

    try {
      final List<Map<String, dynamic>> maps = await _db!.query('products');
      _products.clear();
      _products.addAll(
        maps.map(
          (map) => Product(
            id: map['id'] as String,
            name: map['name'] as String,
            description: map['description'] as String,
            price: (map['price'] as num).toDouble(),
            quantity: map['quantity'] as int,
            imageUrl: map['imageUrl'] as String,
            brandId: (map['brandId'] is int) ? map['brandId'] as int : 0
          ),
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    if (_db == null) return;

    try {
      await _db!.insert('products', product.toMap());
      _products.add(product);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding product: $e');
    }
  }

  Future<void> updateProduct(Product updatedProduct) async {
    if (_db == null) return;

    try {
      await _db!.update(
        'products',
        updatedProduct.toMap(),
        where: 'id = ?',
        whereArgs: [updatedProduct.id],
      );

      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index >= 0) {
        _products[index] = updatedProduct;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating product: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    if (_db == null) return;

    try {
      await _db!.delete('products', where: 'id = ?', whereArgs: [id]);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting product: $e');
    }
  }

  Future<void> reduceInventory(String productId, int quantitySold) async {
    try {
      final product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found'),
      );

      if (product.quantity >= quantitySold) {
        product.quantity -= quantitySold;
        await updateProduct(product);
      }
    } catch (e) {
      debugPrint('Error reducing inventory: $e');
    }
  }

  List<Product> get lowStockProducts =>
      _products.where((p) => p.quantity <= 3).toList();
}
