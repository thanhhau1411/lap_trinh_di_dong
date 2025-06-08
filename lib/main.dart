import 'package:flutter/material.dart';
import 'package:watchstore/models/data/database_helper.dart';
import 'package:watchstore/screens/admin_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AppInitializer());
}

class AppInitializer extends StatefulWidget {
  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isDbReady = false;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    // Xoá database
    // await DatabaseHelper().deleteAppDatabase();
    await DatabaseHelper().database;
    setState(() {
      _isDbReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDbReady) {
      // Hiển thị loading khi DB chưa khởi tạo xong
      return MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    // DB đã sẵn sàng, chạy app chính
    return MyApp();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Watch Store',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AdminDashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
