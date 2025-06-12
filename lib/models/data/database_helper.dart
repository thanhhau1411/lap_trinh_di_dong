// lib/models/data/database_helper.dart
import 'dart:convert'; // Import này có thể không cần thiết nếu bạn không dùng JSON encode/decode trực tiếp ở đây
import 'package:flutter/foundation.dart'; // Thêm dòng này để sử dụng kDebugMode
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:watchstore/models/data/account.dart';
import 'package:watchstore/models/data/customer.dart';
import 'package:watchstore/models/data/product.dart';
import 'package:watchstore/models/data/product_attribute_value.dart';
import 'package:watchstore/models/data/thumbnail.dart';
import 'package:watchstore/models/data/watch_attribute.dart';
import 'package:watchstore/models/data/order.dart';
import 'package:watchstore/models/data/import_receipt.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Delete database file
  static Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'watch_store.db');
    if (await databaseExists(path)) {
      await deleteDatabase(path);
      if (kDebugMode) {
        print("🔥 Database deleted successfully: $path");
      }
    } else {
      if (kDebugMode) {
        print("🤔 Database file not found at: $path (no deletion needed)");
      }
    }
    _database = null; // Đảm bảo reset _database sau khi xóa
  }

  // --- NEW FUNCTIONS FOR REVENUE REPORT & DASHBOARD ---
  // Get all orders
  Future<List<Order>> getAllOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Order');
    return List.generate(maps.length, (i) {
      return Order.fromMap(maps[i]);
    });
  }

  // Get total revenue from successful orders
  Future<double> getTotalRevenue() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT SUM(totalPrice) as total FROM \"Order\" WHERE status = 'thành công'",
    );
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  // Count orders by status
  Future<int> countOrdersByStatus(String status) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM \"Order\" WHERE status = ?",
      [status],
    );
    if (result.isNotEmpty && result.first['count'] != null) {
      return result.first['count'] as int;
    }
    return 0;
  }

  // Get list of orders by specific status
  Future<List<Order>> getOrdersByStatus(String status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Order',
      where: 'status = ?',
      whereArgs: [status],
    );
    return List.generate(maps.length, (i) {
      return Order.fromMap(maps[i]);
    });
  }

  // **HÀM ĐƯỢC THÊM VÀ XÁC NHẬN CÓ Ở ĐÂY**
  // Function to count all products
  Future<int> countAllProducts() async {
    final db = await database;
    final result = await db.rawQuery("SELECT COUNT(*) as count FROM Product");
    if (result.isNotEmpty && result.first['count'] != null) {
      return result.first['count'] as int;
    }
    return 0;
  }

  // **HÀM ĐƯỢC THÊM VÀ XÁC NHẬN CÓ Ở ĐÂY**
  // Function to count products with quantity = 0 (out of stock)
  Future<int> countProductsWithZeroStock() async {
    final db = await database;
    final result = await db.rawQuery("SELECT COUNT(*) as count FROM Product WHERE quantity = 0");
    if (result.isNotEmpty && result.first['count'] != null) {
      return result.first['count'] as int;
    }
    return 0;
  }


  // --- EXISTING FUNCTIONS (rest of your DatabaseHelper methods) ---
  Future<Map<String, int>> getImportReceiptStats() async {
    final db = await database;

    // Get today's date in Malhotra-MM-dd format
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Format date for SQLite (text format 'yyyy-MM-dd')
    String formatDate(DateTime date) =>
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    // 1. Today
    final todayStr = formatDate(today);
    final countTodayResult = await db.rawQuery(
      '''
    SELECT COUNT(*) as count FROM ImportReceipt
    WHERE DATE(importDate) = ?
  ''',
      [todayStr],
    );
    final countToday = Sqflite.firstIntValue(countTodayResult) ?? 0;

    // 2. This week (Monday to Sunday)
    // Calculate Monday of current week
    final weekday = today.weekday; // 1 (Mon) to 7 (Sun)
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

    // 3. This month (1st day to last day of month)
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

    // Get current quantity of product
    final productData = await db.query(
      'Product',
      columns: ['quantity'],
      where: 'id = ?',
      whereArgs: [productId],
    );

    if (productData.isNotEmpty) {
      int currentQuantity = productData.first['quantity'] as int;
      int newQuantity = currentQuantity + quantityToAdd;

      // Update new quantity in Product table
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

  static Future<List<Map<String, dynamic>>> getBrandsRaw() async {
    final db = await DatabaseHelper.database;
    return await db.query('Brand');
  }

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'watch_store.db');
    if (kDebugMode) {
      print("Initializing database at: $path");
    }
    return await openDatabase(
      path,
      version: 3, // Giữ nguyên phiên bản 3
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: onDatabaseDowngradeDelete, // Xóa database nếu downgrade
    );
  }

  // Hàm onUpgrade: được gọi khi phiên bản database cũ hơn phiên bản mới
  // Trong môi trường phát triển, xóa và tạo lại là cách đơn giản nhất để đảm bảo schema mới
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (kDebugMode) {
      print("Upgrading database from version $oldVersion to $newVersion");
    }
    // Xóa tất cả các bảng cũ để tạo lại schema mới
    await db.execute('DROP TABLE IF EXISTS Brand');
    await db.execute('DROP TABLE IF EXISTS Customer');
    await db.execute('DROP TABLE IF EXISTS Product');
    await db.execute('DROP TABLE IF EXISTS WatchAttribute');
    await db.execute('DROP TABLE IF EXISTS ProductAttributeValue');
    await db.execute('DROP TABLE IF EXISTS Thumbnail');
    await db.execute('DROP TABLE IF EXISTS "Order"');
    await db.execute('DROP TABLE IF EXISTS OrderDetail');
    await db.execute('DROP TABLE IF EXISTS OrderDetailAttributeId');
    await db.execute('DROP TABLE IF EXISTS WarrantyCard');
    await db.execute('DROP TABLE IF EXISTS ImportReceipt');
    await db.execute('DROP TABLE IF EXISTS ImportReceiptDetail');
    await db.execute('DROP TABLE IF EXISTS Account');
    
    await _onCreate(db, newVersion); // Gọi lại onCreate để tạo và seed dữ liệu mới
    if (kDebugMode) {
      print("Database upgrade completed and recreated.");
    }
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

  static Future<void> _onCreate(Database db, int version) async {
    if (kDebugMode) {
      print("Creating database tables and seeding initial data...");
    }
    await db.execute('''
      CREATE TABLE Brand (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE Customer (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT,
        phoneNumer TEXT NOT NULL,
        address TEXT NOT NULL,
        imageUrl TEXT
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
        totalPrice REAL,
        FOREIGN KEY (customerId) REFERENCES Customer(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE OrderDetail (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        quantity INTEGER,
        productPrice REAL,
        FOREIGN KEY (orderId) REFERENCES "Order"(id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES Product(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE OrderDetailAttributeId (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderDetailId INTEGER NOT NULL,
        attributeId INTEGER NOT NULL,
        attributeValueId INTEGER NOT NULL,
        FOREIGN KEY (orderDetailId) REFERENCES OrderDetail(id) ON DELETE CASCADE,
        FOREIGN KEY (attributeId) REFERENCES WatchAttribute(attributeId) ON DELETE CASCADE,
        FOREIGN KEY (attributeValueId) REFERENCES ProductAttributeValue(id) ON DELETE CASCADE
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

    await db.execute('''
      CREATE TABLE Account (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        customerId INTEGER,
        FOREIGN KEY (customerId) REFERENCES Customer(id) ON DELETE CASCADE
      );
    ''');

    // Seed data (dữ liệu mẫu)
    await db.insert('Brand', {'name': 'Smart watch'});
    await db.insert('Brand', {'name': 'Casio'});
    await db.insert('Brand', {'name': 'Tissot'});
    await db.insert('Brand', {'name': 'Seiko'});

    final defaultCustomer = Customer(
      fullName: 'admin',
      phoneNumer: '033333333',
      address: '123',
      email: 'admin@gmail.com',
    );
    final defaultAccount = Account(
      username: 'admin@gmail.com',
      password: '123456789',
      customerId: 1,
    );
    await db.insert('Customer', defaultCustomer.toMap());
    await db.insert('Account', defaultAccount.toMap());

    final products = [
      Product(
        name: 'Apple Watch',
        description: 'Series 7',
        price: 799,
        quantity: 5,
        imageUrl: 'https://picsum.photos/seed/200/300',
        brandId: 1,
      ),
      Product(
        name: 'Galaxy Watch',
        description: 'Series 5',
        price: 599,
        quantity: 5,
        imageUrl: 'https://picsum.photos/seed/200/300',
        brandId: 1,
      ),
      Product(
        name: 'Casio G-Shock',
        description: 'Đồng hồ bền bỉ',
        price: 150,
        quantity: 10,
        imageUrl: 'https://picsum.photos/seed/201/300',
        brandId: 2,
      ),
      Product(
        name: 'Tissot Classic',
        description: 'Đồng hồ sang trọng',
        price: 800,
        quantity: 3,
        imageUrl: 'https://picsum.photos/seed/202/300',
        brandId: 3,
      ),
      Product(
        name: 'Seiko 5 Sports',
        description: 'Đồng hồ thể thao',
        price: 300,
        quantity: 0, // Sản phẩm này có số lượng 0 để test cảnh báo
        imageUrl: 'https://picsum.photos/seed/203/300',
        brandId: 4,
      ),
    ];

    final thumbnails = [
      Thumbnail(productId: 1, imageUrl: 'https://picsum.photos/seed/200/300'),
      Thumbnail(productId: 1, imageUrl: 'https://picsum.photos/seed/200/300'),
      Thumbnail(productId: 1, imageUrl: 'https://picsum.photos/seed/200/300'),
      Thumbnail(productId: 2, imageUrl: 'https://picsum.photos/seed/200/300'),
      Thumbnail(productId: 2, imageUrl: 'https://picsum.photos/seed/200/300'),
      Thumbnail(productId: 2, imageUrl: 'https://picsum.photos/seed/200/300'),
      Thumbnail(productId: 3, imageUrl: 'https://picsum.photos/seed/200/300'),
      Thumbnail(productId: 3, imageUrl: 'https://picsum.photos/seed/200/300'),
      Thumbnail(productId: 3, imageUrl: 'https://picsum.photos/seed/200/300'),
      Thumbnail(productId: 4, imageUrl: 'https://picsum.photos/seed/200/300'),
      Thumbnail(productId: 4, imageUrl: 'https://picsum.photos/seed/200/300'),
      Thumbnail(productId: 4, imageUrl: 'https://picsum.photos/seed/200/300'),
      Thumbnail(productId: 5, imageUrl: 'https://picsum.photos/seed/200/300'),
    ];

    final batch = db.batch();
    for (var product in products) {
      batch.insert('Product', {
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'quantity': product.quantity,
        'imageUrl': product.imageUrl,
        'brandId': product.brandId,
      });
    }

    for (var thumb in thumbnails) {
      batch.insert('Thumbnail', thumb.toMap());
    }

    await batch.commit(noResult: true);

    final attributes = [
      WatchAttribute(
        name: 'Chiều dài dây đeo',
        dataType: 'double',
        quantity: 50,
      ),
      WatchAttribute(
        name: 'Đường kính mặt đồng hồ',
        dataType: 'double',
        quantity: 50,
      ),
    ];

    final attributeBatch = db.batch();
    for (var attr in attributes) {
      attributeBatch.insert('WatchAttribute', {
        'name': attr.name,
        'dataType': attr.dataType,
        'quantity': attr.quantity,
      });
    }
    await attributeBatch.commit(noResult: true);

    final attributeValues = [
      ProductAttributeValue(productId: 1, attributeId: 2, value: '42.5'),
      ProductAttributeValue(productId: 1, attributeId: 2, value: '30.5'),
      ProductAttributeValue(productId: 1, attributeId: 1, value: '12.0'),
      ProductAttributeValue(productId: 2, attributeId: 2, value: '44.2'),
      ProductAttributeValue(productId: 3, attributeId: 2, value: '44.2'),
      ProductAttributeValue(productId: 4, attributeId: 2, value: '44.2'),
      ProductAttributeValue(productId: 5, attributeId: 2, value: '40.0'),
    ];

    final valueBatch = db.batch();
    for (var val in attributeValues) {
      valueBatch.insert('ProductAttributeValue', {
        'productId': val.productId,
        'attributeId': val.attributeId,
        'value':
            val.value.toString(),
      });
    }
    await valueBatch.commit(noResult: true);

    // Add sample orders for reporting data
    await db.insert('Order', {
      'orderDate': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      'deliveryDate': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
      'status': 'thành công',
      'customerId': 1,
      'totalPrice': 1500.0,
    });
    await db.insert('Order', {
      'orderDate': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'deliveryDate': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      'status': 'thành công',
      'customerId': 1,
      'totalPrice': 800.0,
    });
    await db.insert('Order', {
      'orderDate': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'deliveryDate': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'status': 'đã hủy',
      'customerId': 1,
      'totalPrice': 150.0,
    });
     await db.insert('Order', {
      'orderDate': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'deliveryDate': DateTime.now().toIso8601String(),
      'status': 'đang chờ',
      'customerId': 1,
      'totalPrice': 799.0,
    });
    if (kDebugMode) {
      print("Database tables created and initial data seeded.");
    }
  }
}
