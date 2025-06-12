import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchstore/controllers/auth_controller.dart';
import 'package:watchstore/controllers/customer_controller.dart';
import 'package:watchstore/controllers/revenue_controller.dart';
import 'package:watchstore/firebase_options.dart';
import 'package:watchstore/models/data/database_helper.dart';
import 'package:watchstore/screens/startapp_screen.dart';
import 'controllers/product_controller.dart';
import 'package:flutter/foundation.dart'; // Import này cần thiết cho kDebugMode

void main() async {
  // Đảm bảo Flutter binding được khởi tạo trước khi gọi bất kỳ Flutter API nào
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Xóa database trước khi khởi tạo ứng dụng trong môi trường phát triển
  // Điều này đảm bảo mỗi lần chạy sẽ có database sạch với dữ liệu mẫu mới nhất
  await DatabaseHelper.deleteDatabaseFile(); // Gọi hàm static để xóa database
  
  runApp(
    // MultiProvider để cung cấp các controller cho toàn bộ ứng dụng
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CustomerController())
        // RevenueController được cung cấp cục bộ trong AdminHomeScreen,
        // nên không cần thêm vào đây.
      ],
      child: const MyApp(), // Sử dụng const cho MyApp
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Thêm constructor const

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Watch Store', // Tiêu đề ứng dụng
      theme: ThemeData(primarySwatch: Colors.blue), // Chủ đề màu sắc
      home: StartApp(), // Màn hình khởi đầu của ứng dụng
      debugShowCheckedModeBanner: false, // Ẩn banner debug
      // Có thể thêm các routes nếu bạn muốn quản lý điều hướng phức tạp hơn
      // initialRoute: '/',
      // routes: {
      //   '/': (context) => const HomeScreen(),
      //   '/productDetail': (context) => const ProductDetailScreen(),
      // },
    );
  }
}
