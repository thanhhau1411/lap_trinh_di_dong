import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'watch_store.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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
        id TEXT PRIMARY KEY,
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
      CREATE TABLE WatchSize (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        caseDiameter REAL,
        thickness REAL,
        bandWidth REAL,
        bandLength REAL
      );
    ''');

    await db.execute('''
      CREATE TABLE ProductSize (
        productId TEXT,
        sizeId INTEGER,
        PRIMARY KEY (productId, sizeId),
        FOREIGN KEY (productId) REFERENCES Product(id),
        FOREIGN KEY (sizeId) REFERENCES WatchSize(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE Thumbnail (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        FOREIGN KEY (productId) REFERENCES Product(id)
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
        productId TEXT NOT NULL,
        FOREIGN KEY (orderId) REFERENCES "Order"(id),
        FOREIGN KEY (productId) REFERENCES Product(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE WarrantyCard (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderDetail INTEGER NOT NULL,
        issuedDate TEXT NOT NULL,
        expiryDate TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (orderDetail) REFERENCES OrderDetail(id)
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
        FOREIGN KEY (importReceiptId) REFERENCES ImportReceipt(id),
        FOREIGN KEY (productId) REFERENCES Product(id)
      );
    ''');
  }
}
