import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchstore/controllers/auth_controller.dart';
import 'package:watchstore/controllers/order_controller.dart';
import 'package:watchstore/models/data/customer.dart';
import 'package:watchstore/screens/favorite_screen.dart';
import 'package:watchstore/screens/home_screen.dart';
import 'package:watchstore/screens/login_screen.dart';
import 'package:watchstore/screens/order_history_screen.dart';
import 'package:watchstore/screens/user_profile_screen.dart';

Widget buildDrawerHeader(BuildContext context, Customer? customerInfo) {
  return Column(
    children: [
      DrawerHeader(
        decoration: BoxDecoration(color: Colors.red.shade300),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage:
                  (customerInfo?.imageUrl != null)
                      ? FileImage(File(customerInfo!.imageUrl!))
                      : NetworkImage('https://i.imgur.com/6lSn8cN.png'),
            ),
            SizedBox(width: 16),
            Text(
              customerInfo?.fullName ?? 'Empty',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
      _buildDrawerItem(Icons.home, "Trang chủ", () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
          (routes) => false,
        );
      }),
      _buildDrawerItem(Icons.person, "Hồ sơ cá nhân", () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfileScreen()),
        );
      }),
      _buildDrawerItem(Icons.favorite, "Yêu thích", () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FavoriteScreen()),
        );
      }),
      _buildDrawerItem(Icons.receipt_long, "Đơn hang", () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ChangeNotifierProvider(
                  create: (context) => OrderController(),
                  child: OrderHistoryScreen(customerId: customerInfo?.id ?? -1),
                ),
          ),
        );
      }),
      // _buildDrawerItem(Icons.settings, "Cài đặt", () {}),0
      const Spacer(),
      _buildDrawerItem(Icons.logout, "Đăng xuất", () {
        final authController = context.read<AuthController>();
        authController.customerInfo = null;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (routes) => false,
        );
      }),
    ],
  );
}

Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
  return ListTile(
    leading: Icon(icon, color: Colors.red.shade400),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
    onTap: onTap,
  );
}
