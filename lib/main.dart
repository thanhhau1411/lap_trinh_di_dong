import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/product_controller.dart';
import '../screens/admin_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final productController = ProductController();
  await productController.initDb();

  runApp(
    ChangeNotifierProvider<ProductController>.value(
      value: productController,
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
      home: AdminHomeScreen(),
    );
  }
}
