import 'package:watchstore/models/data/brand.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:watchstore/models/data/database_helper.dart';
import 'package:watchstore/models/data/product_attribute_value.dart';
import 'package:watchstore/models/data/thumbnail.dart';
import 'package:watchstore/models/data/watch_attribute.dart';
import '../models/data/product.dart';

class ProductController extends ChangeNotifier {
  late Database _db;
  final List<Product> _products = [];

  List<Product> get products => List.unmodifiable(_products);

  Future<void> loadProductsFromDb() async {
    _db = await DatabaseHelper.database;
    if (_db == null) return;

    try {
      final List<Map<String, dynamic>> maps = await _db!.query('products');
      _products.clear();
      _products.addAll(
        maps.map(
          (map) => Product(
            id: map['id'] as int,
            name: map['name'] as String,
            description: map['description'] as String,
            price: (map['price'] as num).toDouble(),
            quantity: map['quantity'] as int,
            imageUrl: map['imageUrl'] as String,
            brandId: (map['brandId'] is int) ? map['brandId'] as int : 0,
          ),
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    _db = await DatabaseHelper.database;
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
    _db = await DatabaseHelper.database;
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

  Future<void> deleteProduct(int id) async {
    _db = await DatabaseHelper.database;
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
    _db = await DatabaseHelper.database;
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

  Future<Product?> getProductById(int productId) async {
    _db = await DatabaseHelper.database;
    final result = await _db.query(
      'product',
      where: 'id = ?',
      whereArgs: [productId],
    );
    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<List<Product>> getProductByBrandId(int brandId) async {
    _db = await DatabaseHelper.database;
    final result = await _db.rawQuery(
      '''select * 
                                         from Product p 
                                         join Brand b on b.id = p.brandId
                                         where b.id = ?
                                      ''',
      [brandId],
    );
    if (result.isNotEmpty) {
      return result.map((map) => Product.fromMap(map)).toList();
    } else {
      return <Product>[];
    }
  }

  Future<List<Product>> getAll() async {
    _db = await DatabaseHelper.database;
    final result = await _db.query('Product');
    if (result.isNotEmpty) {
      return result.map((map) => Product.fromMap(map)).toList();
    } else {
      return <Product>[];
    }
  }

  Future<List<WatchAttribute>?> getWatchAttribute(int productId) async {
    final db = await DatabaseHelper.database;
    final result = await db.rawQuery(
      '''  select  wa.attributeId, wa.name, wa.dataType, wa.quantity
                     from Product p 
                     join ProductAttributeValue pav on pav.productId = p.id
                     join WatchAttribute wa on wa.attributeId = pav.attributeId
                     where p.id = ?
                ''',
      [productId],
    );
    if (result.isNotEmpty) {
      return result.map((map) => WatchAttribute.fromMap(map)).toList();
    } else {
      return null;
    }
  }

  Future<ProductAttributeValue?> getAttributeValue(
    int productId,
    int attributeId,
  ) async {
    final db = await DatabaseHelper.database;
    final result = await db.rawQuery(
      '''
    SELECT pav.id, pav.productId, pav.attributeId, pav.value
    FROM Product p 
    JOIN ProductAttributeValue pav ON pav.productId = p.id
    JOIN WatchAttribute wa ON wa.attributeId = pav.attributeId
    WHERE p.id = ? AND wa.attributeId = ?
    ''',
      [productId, attributeId],
    );

    if (result.isNotEmpty) {
      return ProductAttributeValue.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<List<ProductAttributeValue>?> getAllAttributeValues(
    int productId,
  ) async {
    final db = await DatabaseHelper.database;
    final result = await db.rawQuery(
      '''
    SELECT pav.id, pav.productId, pav.attributeId, pav.value
    FROM Product p 
    JOIN ProductAttributeValue pav ON pav.productId = p.id
    JOIN WatchAttribute wa ON wa.attributeId = pav.attributeId
    WHERE p.id = ?
    ''',
      [productId],
    );

    if (result.isNotEmpty) {
      return result.map((map) => ProductAttributeValue.fromMap(map)).toList();
    } else {
      return null;
    }
  }

  Future<List<Thumbnail>> getThumbnail(int productId) async {
    final db = await DatabaseHelper.database;
    var result = await db.query(
      'Thumbnail',
      where: 'productId = ?',
      whereArgs: [productId],
    );
    if (result.isNotEmpty) {
      return result.map((map) => Thumbnail.fromMap(map)).toList();
    } else {
      return [];
    }
  }

  Future<List<Product>> getProducts() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Product');
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<List<Brand>> getBrands() async {
    final dbHelper = DatabaseHelper();
    final List<Map<String, dynamic>> maps = await DatabaseHelper.getBrandsRaw();

    return List.generate(maps.length, (i) {
      return Brand.fromMap(maps[i]);
    });
  }

  Future<int> countProductsWithZeroStock() async {
    final db = await DatabaseHelper.database;

    final result = await db.rawQuery('''
    SELECT COUNT(*) AS total FROM Product WHERE quantity = 0
  ''');

    // Lấy số lượng từ kết quả truy vấn
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count;
  }

  Future<int> countAllProducts() async {
    final db = await DatabaseHelper.database;

    final result = await db.rawQuery('''
    SELECT COUNT(*) AS total FROM Product
  ''');

    final count = Sqflite.firstIntValue(result) ?? 0;
    return count;
  }
}

  Future<int> countProductsWithZeroStock() async {
    final db = await DatabaseHelper.database;

    final result = await db.rawQuery('''
    SELECT COUNT(*) AS total FROM Product WHERE quantity = 0
  ''');

    // Lấy số lượng từ kết quả truy vấn
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count;
  }

  Future<int> countAllProducts() async {
  final db = await DatabaseHelper.database;

  final result = await db.rawQuery('''
    SELECT COUNT(*) AS total FROM Product
  ''');

  final count = Sqflite.firstIntValue(result) ?? 0;
  return count;
}

Future<List<Product>> getProducts() async {
  final db = await DatabaseHelper.database;
  final List<Map<String, dynamic>> maps = await db.query('Product');
  return List.generate(maps.length, (i) {
    return Product.fromMap(maps[i]);
  });
}

Future<List<Brand>> getBrands() async {
  final List<Map<String, dynamic>> maps = await DatabaseHelper.getBrandsRaw();

  return List.generate(maps.length, (i) {
    return Brand.fromMap(maps[i]);
  });
}