import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:watchstore/models/data/product.dart';
import 'package:watchstore/models/data/product_attribute_value.dart';
import 'package:watchstore/models/data/watch_attribute.dart';

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

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'watch_store.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> deleteDatabaseFile() async {
    final path = join(await getDatabasesPath(), 'watch_store.db');
    await deleteDatabase(path);
    print("🔥 Database deleted");
  }

  static Future<void> _onCreate(Database db, int version) async {
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
        productId TEXT NOT NULL,
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
        FOREIGN KEY (customerId) REFERENCES Cutomer(id) ON DELETE CASCADE
      );
    ''');

    // insert
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

    await db.insert('Brand', {'name': 'Smart watch'});
    await db.insert('Brand', {'name': 'Casio'});
    await db.insert('Brand', {'name': 'Tissot'});

    final products = [
      Product(
        name: 'Apple Watch',
        description: 'Series 7',
        price: 799,
        quantity: 5,
        imageUrl: 'https://picsum.photos/200/300',
        brandId: 1,
      ),
      Product(
        name: 'Galaxy Watch',
        description: 'Series 5',
        price: 599,
        quantity: 5,
        imageUrl: 'https://picsum.photos/200/300',
        brandId: 1,
      ),
      Product(
        name: 'Galaxy Watch',
        description: 'Series 5',
        price: 599,
        quantity: 5,
        imageUrl: 'https://picsum.photos/200/300',
        brandId: 2,
      ),
      Product(
        name: 'Galaxy Watch',
        description: 'Series 5',
        price: 599,
        quantity: 5,
        imageUrl: 'https://picsum.photos/200/300',
        brandId: 3,
      ),
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
    await batch.commit(noResult: true);

    final attributes = [
      WatchAttribute(name: 'Chiều dài dây đeo', dataType: 'double', quantity: 50),
      WatchAttribute(name: 'Đường kính mặt đồng hồ', dataType: 'double', quantity: 50),
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
      ProductAttributeValue(productId: 1, attributeId: 3, value: '42.5'),
      ProductAttributeValue(productId: 1, attributeId: 4, value: '12.0'),
      ProductAttributeValue(productId: 2, attributeId: 3, value: '44.2'),
    ];

    final valueBatch = db.batch();
    for (var val in attributeValues) {
      valueBatch.insert('ProductAttributeValue', {
        'productId': val.productId,
        'attributeId': val.attributeId,
        'value':
            val.value.toString(), // đảm bảo lưu chuỗi (hoặc convert nếu cần)
      });
    }
    await valueBatch.commit(noResult: true);
  }
}
