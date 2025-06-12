// lib/screens/admin_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_list_screen.dart';
import 'inventory_screen.dart'; // Màn hình tồn kho (nếu có)
import 'revenue_report_screen.dart'; // Màn hình báo cáo doanh thu
import '../controllers/revenue_controller.dart'; // RevenueController
import 'package:watchstore/models/data/database_helper.dart'; // DatabaseHelper

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // Loại bỏ _totalProducts vì chúng ta sẽ dùng FutureBuilder và RevenueController

  // Hàm định dạng tiền tệ
  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K'; // Không cần thập phân cho K
    }
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    // Cung cấp RevenueController cho AdminHomeScreen và các widget con
    return ChangeNotifierProvider(
      create: (_) => RevenueController(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'Admin Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF0078D7),
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.account_circle_outlined,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0078D7), Color(0xFF2899F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x4D0078D7),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chào mừng trở lại!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Quản lý cửa hàng đồng hồ của bạn',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Stats Cards Section - Sử dụng Consumer để lắng nghe dữ liệu động
              Consumer<RevenueController>(
                builder: (context, revenueController, child) {
                  if (revenueController.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    children: [
                      // Hàng đầu tiên: Tổng doanh thu và Tổng đơn hàng
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatsCard(
                              icon: Icons.trending_up,
                              title: 'Tổng doanh thu',
                              value: '₫${_formatCurrency(revenueController.totalRevenue)}', // Dữ liệu động từ RevenueController
                              color: Colors.green,
                              context: context,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatsCard(
                              icon: Icons.shopping_bag,
                              title: 'Tổng đơn hàng',
                              value: '${revenueController.totalOrdersCount}', // Dữ liệu động từ RevenueController
                              color: Colors.blue,
                              context: context,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Hàng thứ hai: Tổng sản phẩm và Cảnh báo
                      Row(
                        children: [
                          Expanded(
                            child: FutureBuilder<int>(
                              future: DatabaseHelper().countAllProducts(), // Lấy tổng sản phẩm từ DatabaseHelper
                              builder: (context, snapshot) {
                                final productCount = snapshot.data ?? 0;
                                return _buildStatsCard(
                                  icon: Icons.inventory_2,
                                  title: 'Tổng sản phẩm',
                                  value: '$productCount',
                                  color: Colors.orange,
                                  context: context,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FutureBuilder<int>(
                              future: DatabaseHelper().countProductsWithZeroStock(), // Lấy sản phẩm hết hàng từ DatabaseHelper
                              builder: (context, snapshot) {
                                final outOfStockCount = snapshot.data ?? 0;
                                return _buildStatsCard(
                                  icon: Icons.warning,
                                  title: 'Cảnh báo',
                                  value: '$outOfStockCount',
                                  color: Colors.red,
                                  context: context,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Management Section Title
              const Text(
                'Quản lý hệ thống',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Management Cards Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
                children: [
                  _buildManagementCard(
                    context: context,
                    icon: Icons.watch,
                    title: 'Quản lý\nSản phẩm',
                    subtitle: 'Thêm, sửa, xóa sản phẩm',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProductListScreen()),
                      );
                    },
                  ),
                  _buildManagementCard(
                    context: context,
                    icon: Icons.inventory,
                    title: 'Quản lý\nTồn kho',
                    subtitle: 'Theo dõi số lượng',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => InventoryScreen()),
                      );
                    },
                  ),
                  _buildManagementCard(
                    context: context,
                    icon: Icons.analytics,
                    title: 'Báo cáo\nThống kê',
                    subtitle: 'Xem doanh thu, bán chạy',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RevenueReportScreen(),
                        ),
                      );
                    },
                  ),
                  _buildManagementCard(
                    context: context,
                    icon: Icons.people,
                    title: 'Quản lý\nKhách hàng',
                    subtitle: 'Danh sách khách hàng',
                    color: Colors.indigo,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng đang phát triển'),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Quick Actions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thao tác nhanh',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickAction(
                          icon: Icons.add_circle,
                          label: 'Thêm SP',
                          color: Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductListScreen(),
                              ),
                            );
                          },
                        ),
                        _buildQuickAction(
                          icon: Icons.warning,
                          label: 'Cảnh báo',
                          color: Colors.red,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => InventoryScreen(),
                              ),
                            );
                          },
                        ),
                        _buildQuickAction(
                          icon: Icons.backup,
                          label: 'Sao lưu',
                          color: Colors.blue,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đang sao lưu dữ liệu...'),
                              ),
                            );
                          },
                        ),
                        _buildQuickAction(
                          icon: Icons.settings,
                          label: 'Cài đặt',
                          color: Colors.grey,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tính năng đang phát triển'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm _buildStatsCard đã có sẵn trong AdminHomeScreen của bạn
  Widget _buildStatsCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // Hàm _buildManagementCard đã có sẵn
  Widget _buildManagementCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm _buildQuickAction đã có sẵn
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
