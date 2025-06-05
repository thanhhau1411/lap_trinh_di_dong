import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchstore/models/data/brand.dart';
import 'package:watchstore/models/data/database_helper.dart';
import 'package:watchstore/models/data/product.dart';
import 'package:watchstore/screens/home_screen.dart';
import 'controllers/product_controller.dart';
import '../screens/admin_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final databaseHelper = DatabaseHelper();
  // await databaseHelper.database;

   runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductController()),
        // Thêm các Provider khác tại đây nếu có
        // ChangeNotifierProvider(create: (_) => OrderController()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Watch Store',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
