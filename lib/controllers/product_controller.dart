import 'package:sqflite/sqflite.dart';
import 'package:watchstore/models/data/brand.dart';
import 'package:watchstore/models/data/database_helper.dart';
import 'package:watchstore/models/data/product.dart';

Future<List<Product>> getProducts() async {
  final db = await DatabaseHelper().database;
  final List<Map<String, dynamic>> maps = await db.query('Product');
  return List.generate(maps.length, (i) {
    return Product.fromMap(maps[i]);
  });
}

Future<List<Brand>> getBrands() async {
  final dbHelper = DatabaseHelper();
  final List<Map<String, dynamic>> maps = await dbHelper.getBrandsRaw();

  return List.generate(maps.length, (i) {
    return Brand.fromMap(maps[i]);
  });
}

Future<int> countProductsWithZeroStock() async {
  final db = await DatabaseHelper().database;

  final result = await db.rawQuery('''
    SELECT COUNT(*) AS total FROM Product WHERE quantity = 0
  ''');

  // Lấy số lượng từ kết quả truy vấn
  final count = Sqflite.firstIntValue(result) ?? 0;
  return count;
}

Future<int> countAllProducts() async {
  final db = await DatabaseHelper().database;

  final result = await db.rawQuery('''
    SELECT COUNT(*) AS total FROM Product
  ''');

  final count = Sqflite.firstIntValue(result) ?? 0;
  return count;
}
