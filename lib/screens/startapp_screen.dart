import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchstore/controllers/auth_controller.dart';
import 'package:watchstore/screens/home_screen.dart';
import 'package:watchstore/screens/login_screen.dart';

class StartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(252, 248, 248, 248), // Sửa màu sắc với mã HEX chính xác
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Tiêu đề
                Text(
                  "WATCH\nSTORE",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 55,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                // Tạo khoảng cách với Spacer
                Spacer(flex: 1),
                // Hình ảnh đồng hồ
                Image(
                  image: AssetImage("assets/images/series_7.jpg"),
                  height: 350,
                ),
                Spacer(flex: 1),
                // Mô tả ngắn về cửa hàng
                Text(
                  "Find your Fashion Watch Here",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
                Spacer(flex: 1),
                // Nút bấm
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => LoginScreen()
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    foregroundColor: Colors.white,
                    iconColor: Colors.white,
                    backgroundColor: Color(0xFFED5443), // Màu nút
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Get Started"),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
                Spacer(flex: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
