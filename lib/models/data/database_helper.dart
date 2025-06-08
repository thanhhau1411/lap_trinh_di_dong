import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:watchstore/models/data/import_receipt.dart';
import 'package:watchstore/models/data/product.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Xóa database
  Future<void> deleteAppDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'watch_store.db');
    await deleteDatabase(path);
  }

  Future<Map<String, int>> getImportReceiptStats() async {
    final db = await database;

    // Lấy ngày hôm nay ở dạng yyyy-MM-dd
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Định dạng ngày cho SQLite (text format 'yyyy-MM-dd')
    String formatDate(DateTime date) =>
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    // 1. Hôm nay
    final todayStr = formatDate(today);
    final countTodayResult = await db.rawQuery(
      '''
    SELECT COUNT(*) as count FROM ImportReceipt
    WHERE DATE(importDate) = ?
  ''',
      [todayStr],
    );
    final countToday = Sqflite.firstIntValue(countTodayResult) ?? 0;

    // 2. Tuần này (từ thứ 2 đến Chủ nhật)
    // Tính ngày thứ 2 của tuần hiện tại
    final weekday = today.weekday; // 1 (Mon) đến 7 (Sun)
    final monday = today.subtract(Duration(days: weekday - 1));
    final sunday = monday.add(Duration(days: 6));

    final mondayStr = formatDate(monday);
    final sundayStr = formatDate(sunday);

    final countWeekResult = await db.rawQuery(
      '''
    SELECT COUNT(*) as count FROM ImportReceipt
    WHERE DATE(importDate) BETWEEN ? AND ?
  ''',
      [mondayStr, sundayStr],
    );
    final countWeek = Sqflite.firstIntValue(countWeekResult) ?? 0;

    // 3. Tháng này (từ ngày 1 đến cuối tháng)
    final firstDayOfMonth = DateTime(today.year, today.month, 1);
    final nextMonth =
        (today.month < 12)
            ? DateTime(today.year, today.month + 1, 1)
            : DateTime(today.year + 1, 1, 1);
    final lastDayOfMonth = nextMonth.subtract(Duration(days: 1));

    final firstDayStr = formatDate(firstDayOfMonth);
    final lastDayStr = formatDate(lastDayOfMonth);

    final countMonthResult = await db.rawQuery(
      '''
    SELECT COUNT(*) as count FROM ImportReceipt
    WHERE DATE(importDate) BETWEEN ? AND ?
  ''',
      [firstDayStr, lastDayStr],
    );
    final countMonth = Sqflite.firstIntValue(countMonthResult) ?? 0;

    return {'today': countToday, 'week': countWeek, 'month': countMonth};
  }

  Future<void> updateProductQuantity(int productId, int quantityToAdd) async {
    final db = await database;

    // Lấy số lượng hiện tại của sản phẩm
    final productData = await db.query(
      'Product',
      columns: ['quantity'],
      where: 'id = ?',
      whereArgs: [productId],
    );

    if (productData.isNotEmpty) {
      int currentQuantity = productData.first['quantity'] as int;
      int newQuantity = currentQuantity + quantityToAdd;

      // Cập nhật số lượng mới vào bảng Product
      await db.update(
        'Product',
        {'quantity': newQuantity},
        where: 'id = ?',
        whereArgs: [productId],
      );
    }
  }

  Future<int> insertImportReceipt(ImportReceipt receipt) async {
    final db = await database;
    return await db.insert('ImportReceipt', receipt.toMap());
  }

  Future<int> deleteProduct(int productId) async {
    final db = await database;
    return await db.delete('Product', where: 'id = ?', whereArgs: [productId]);
  }

  Future<void> insertImportReceiptDetail(
    int receiptId,
    int productId,
    int quantity,
  ) async {
    final db = await database;
    await db.insert('ImportReceiptDetail', {
      'importReceiptId': receiptId,
      'productId': productId,
      'quantity': quantity,
    });
  }

  Future<List<Map<String, dynamic>>> getProductsByReceiptId(
    int receiptId,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
    SELECT p.id, p.name, p.price, p.imageUrl, ird.quantity,
           (ird.quantity * p.price) as total
    FROM ImportReceiptDetail ird
    JOIN Product p ON ird.productId = p.id
    WHERE ird.importReceiptId = ?
  ''',
      [receiptId],
    );

    return result;
  }

  Future<Map<String, dynamic>?> getReceiptByIdFromDB(int receiptId) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
    SELECT ir.id, ir.importDate, ir.supplierName, ir.staffName, ir.notes,
           COUNT(ird.id) AS productCount,
           IFNULL(SUM(ird.quantity * p.price), 0) AS totalAmount,
           GROUP_CONCAT(p.id) AS productIds
    FROM ImportReceipt ir
    LEFT JOIN ImportReceiptDetail ird ON ir.id = ird.importReceiptId
    LEFT JOIN Product p ON ird.productId = p.id
    WHERE ir.id = ?
    GROUP BY ir.id
    LIMIT 1
  ''',
      [receiptId],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllImportReceiptsWithStats() async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT ir.id, ir.importDate, ir.supplierName, ir.staffName,
           COUNT(ird.id) AS productCount,
           IFNULL(SUM(ird.quantity * p.price), 0) AS totalAmount,
           GROUP_CONCAT(p.id) AS productIds
    FROM ImportReceipt ir
    LEFT JOIN ImportReceiptDetail ird ON ir.id = ird.importReceiptId
    LEFT JOIN Product p ON ird.productId = p.id
    GROUP BY ir.id
    ORDER BY ir.importDate DESC
  ''');

    return result;
  }

  Future<List<Map<String, dynamic>>> getProductsWithBrand() async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT p.id, p.name, p.description, p.price, p.quantity, p.imageUrl, p.brandId,
           b.name as brandName
    FROM Product p
    INNER JOIN Brand b ON p.brandId = b.id
  ''');

    return results;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'watch_store.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<int> insertProduct({
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String imageUrl,
    required int brandId,
  }) async {
    final db = await database;
    return await db.insert('Product', {
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'brandId': brandId,
    });
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Brand (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      );
    ''');

    await db.insert('Brand', {'name': 'Rolex'});
    await db.insert('Brand', {'name': 'Casio'});
    await db.insert('Brand', {'name': 'Orient'});
    await db.insert('Brand', {'name': 'Citizen'});

    await db.execute('''
      CREATE TABLE Customer (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT,
        phoneNumer TEXT NOT NULL,
        address TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE Product (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        imageUrl TEXT NOT NULL,
        brandId INTEGER NOT NULL,
        FOREIGN KEY (brandId) REFERENCES Brand(id)
      );
    ''');

    await db.insert('Product', {
      'name': 'Đồng hồ Rolex Datejust',
      'description': 'Đồng hồ lặn biểu tượng, chịu nước 300m',
      'price': 1000000,
      'quantity': 10,
      'imageUrl': 'rolex.jpg',
      'brandId': 1,
    });

    await db.insert('Product', {
      'name': 'Đồng hồ CASIO EDIFICE',
      'description': 'Đồng hồ lặn cổ điển với van thoát khí heli',
      'price': 2000000,
      'quantity': 10,
      'imageUrl': 'casio.jpg',
      'brandId': 2,
    });

    await db.insert('Product', {
      'name': 'Đồng hồ Orient',
      'description': 'Đồng hồ thể thao bền bỉ và đáng tin cậy',
      'price': 3000000,
      'quantity': 5,
      'imageUrl': 'orient.jpg',
      'brandId': 3,
    });

    await db.insert('Product', {
      'name': 'Đồng hồ Citizen',
      'description': 'Đồng hồ đẹp, sang trọng quý phái',
      'price': 3000000,
      'quantity': 0,
      'imageUrl': 'citizen.jpg',
      'brandId': 4,
    });

    await db.execute('''
      CREATE TABLE WatchAttribute (
        attributeId INTEGER PRIMARY KEY AUTOINCREMENT,
        name Text NOT NULL,
        dataType Text NOT NULL,
        quantity INTEGER NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE ProductAttributeValue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER,
        attributeId INTEGER,
        value TEXT NOT NULL,
        FOREIGN KEY (productId) REFERENCES Product(id) ON DELETE CASCADE,
        FOREIGN KEY (attributeId) REFERENCES WatchAttribute(attributeId) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE Thumbnail (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        imageUrl TEXT NOT NULL,
        FOREIGN KEY (productId) REFERENCES Product(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE "Order" (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderDate TEXT NOT NULL,
        deliveryDate TEXT NOT NULL,
        status TEXT,
        customerId INTEGER NOT NULL,
        FOREIGN KEY (customerId) REFERENCES Customer(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE OrderDetail (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        FOREIGN KEY (orderId) REFERENCES "Order"(id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES Product(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE WarrantyCard (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderDetail INTEGER NOT NULL,
        issuedDate TEXT NOT NULL,
        expiryDate TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (orderDetail) REFERENCES OrderDetail(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE ImportReceipt (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        importDate TEXT NOT NULL,
        supplierName TEXT NOT NULL,
        staffName TEXT NOT NULL,
        notes TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE ImportReceiptDetail (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        importReceiptId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (importReceiptId) REFERENCES ImportReceipt(id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES Product(id) ON DELETE CASCADE
      );
    ''');

    await db.insert('WatchAttribute', {
      'name': 'bandLength',
      'dataType': 'double',
      'quantity': 50,
    });

    await db.insert('WatchAttribute', {
      'name': 'thickness',
      'dataType': 'double',
      'quantity': 50,
    });

    await db.insert('WatchAttribute', {
      'name': 'caseDiameter',
      'dataType': 'double',
      'quantity': 50,
    });
  }

  // Hàm lấy danh sách brand
  Future<List<Map<String, dynamic>>> getBrandsRaw() async {
    final db = await database;
    return await db.query('Brand');
  }
}
