import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchstore/controllers/auth_controller.dart';
import 'package:watchstore/controllers/customer_controller.dart';
import 'package:watchstore/firebase_options.dart';
import 'package:watchstore/models/data/database_helper.dart';
import 'package:watchstore/screens/startapp_screen.dart';
import 'controllers/product_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await DatabaseHelper.deleteDatabaseFile();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CustomerController())
        // Thêm các Provider khác tại đây nếu có
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
      home: StartApp(),
      debugShowCheckedModeBanner: false,
      // initialRoute: '/',
      // routes: {
      //   '/': (context) => HomeScreen(),
      //   '/productDetail': (context) => ProductDetailScreen(),
      // },
    );
  }
}
