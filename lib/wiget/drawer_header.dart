import 'package:flutter/material.dart';
import 'package:watchstore/screens/home_screen.dart';

Widget buildDrawerHeader(BuildContext context) {
  return Column(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.red.shade300,
          ),
          child: Row(
            children: const [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage('https://i.imgur.com/6lSn8cN.png'),
              ),
              SizedBox(width: 16),
              Text(
                "Xin chào!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        _buildDrawerItem(Icons.home, "Trang chủ", () { Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeScreen()), (routes) => false);}),
        _buildDrawerItem(Icons.shopping_cart, "Giỏ hàng", () {}),
        _buildDrawerItem(Icons.favorite, "Yêu thích", () {}),
        _buildDrawerItem(Icons.receipt_long, "Đơn hàng", () {}),
        _buildDrawerItem(Icons.settings, "Cài đặt", () {}),
        const Spacer(),
        _buildDrawerItem(Icons.logout, "Đăng xuất", () {}),
      ]);
}

Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
  return ListTile(
    leading: Icon(icon, color: Colors.red.shade400),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
    onTap: onTap,
  );
}
