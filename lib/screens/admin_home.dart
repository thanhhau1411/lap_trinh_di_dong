import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:watchstore/controllers/product_controller.dart'; // Giữ nếu dùng, nếu không thì có thể xóa
import 'package:watchstore/controllers/revenue_controller.dart';
import 'package:watchstore/screens/inventory_screen.dart'; // Đảm bảo import đúng tên file của màn hình tồn kho
import 'package:watchstore/screens/product_list_screen.dart'; // Màn hình quản lý sản phẩm
import 'package:watchstore/screens/revenue_report_screen.dart';
import 'package:watchstore/models/data/database_helper.dart'; // Import DatabaseHelper để lấy số lượng sản phẩm và cảnh báo

// Đây là class AdminDashboardScreen mà bạn đã cung cấp, được đặt trong admin_home.dart
class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Hàm định dạng tiền tệ
  String _formatCurrency(double amount) {
    if (amount >= 1000000000) { // Tỷ
      return '${(amount / 1000000000).toStringAsFixed(1)}Bvnd';
    } else if (amount >= 1000000) { // Triệu
      return '${(amount / 1000000).toStringAsFixed(1)}Mvnd';
    } else { // Dưới 1 triệu, hiển thị đầy đủ với 2 chữ số thập phân
      return '${amount.toStringAsFixed(2)}vnd';
    }
  }

  @override
  Widget build(BuildContext context) { // Giữ nguyên context hoặc đổi thành buildContext nếu bạn muốn
    // Cung cấp RevenueController tại đây cho màn hình này
    return ChangeNotifierProvider(
      create: (_) => RevenueController(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.dashboard_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bảng điều khiển',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            'Quản lý toàn bộ hệ thống',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statistics Cards - Sử dụng Consumer để lắng nghe dữ liệu động
                      Consumer<RevenueController>(
                        builder: (context, revenueController, child) {
                          if (revenueController.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          // Khi dữ liệu đã tải xong, hiển thị các card
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Tổng doanh thu',
                                      // Sử dụng hàm định dạng mới
                                      '${_formatCurrency(revenueController.totalRevenue)}', 
                                      Icons.trending_up_rounded,
                                      const Color(0xFF10B981),
                                      // Ví dụ về % thay đổi, cần logic thực tế để tính toán chính xác
                                      '+${(revenueController.totalRevenue > 0 ? (revenueController.totalRevenue / 1000 * 10).toStringAsFixed(1) : 0)}%',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Đơn hàng',
                                      '${revenueController.totalOrdersCount}', // Dữ liệu động từ RevenueController
                                      Icons.shopping_bag_rounded,
                                      const Color(0xFF3B82F6),
                                      // Ví dụ về % thay đổi
                                      '+${(revenueController.totalOrdersCount > 0 ? (revenueController.totalOrdersCount / 10 * 10).toStringAsFixed(1) : 0)}%',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: FutureBuilder<int>(
                                      // Lấy tổng sản phẩm từ DatabaseHelper
                                      future: DatabaseHelper().countAllProducts(),
                                      builder: (context, snapshot) {
                                        final productCount = snapshot.data ?? 0;
                                        return _buildStatCard(
                                          'Sản phẩm',
                                          productCount.toString(),
                                          Icons.inventory_2_rounded,
                                          const Color(0xFFF59E0B),
                                          // Ví dụ về % thay đổi
                                          '+${(productCount > 0 ? (productCount / 2 * 10).toStringAsFixed(0) : 0)}',
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: FutureBuilder<int>(
                                      // Lấy sản phẩm hết hàng từ DatabaseHelper
                                      future: DatabaseHelper().countProductsWithZeroStock(),
                                      builder: (context, snapshot) {
                                        final outOfStockCount = snapshot.data ?? 0;
                                        return _buildStatCard(
                                          'Cảnh báo',
                                          outOfStockCount.toString(),
                                          Icons.warning_rounded,
                                          const Color(0xFFEF4444),
                                          'Hết hàng', // Có thể hiển thị số lượng cụ thể
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

                      const SizedBox(height: 30),

                      // Quick Actions
                      const Text(
                        'Thao tác nhanh',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.0,
                        children: [
                          _buildQuickActionCard(
                            'Quản lý kho',
                            'Thêm, sửa, xóa sản phẩm',
                            Icons.warehouse_rounded,
                            const Color(0xFF8B5CF6),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductListScreen(), // Chuyển đến ProductListScreen
                                ),
                              );
                            },
                          ),
                          _buildQuickActionCard(
                            'Đổi trả',
                            'Xử lý yêu cầu đổi/trả',
                            Icons.sync_rounded,
                            const Color(0xFF06B6D4),
                            () => _navigateToReturns(),
                          ),
                          _buildQuickActionCard(
                            'Bảo hành',
                            'Quản lý thông tin bảo hành',
                            Icons.verified_user_rounded,
                            const Color(0xFF10B981),
                            () => _navigateToWarranty(),
                          ),
                          _buildQuickActionCard(
                            'Báo cáo',
                            'Thống kê doanh số',
                            Icons.bar_chart_rounded,
                            const Color(0xFFFF6B6B),
                            () => _navigateToReports(), // Gọi hàm điều hướng
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for building statistic cards
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for building quick action cards
  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
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
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder navigation functions
  void _navigateToReturns() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng Đổi trả đang phát triển')),
    );
  }

  void _navigateToWarranty() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng Bảo hành đang phát triển')),
    );
  }

  void _navigateToReports() {
    Navigator.push(
      context,
      MaterialPageRoute(
        // ĐÃ SỬA: Đảm bảo RevenueController được cung cấp lại tại đây
        builder: (context) => ChangeNotifierProvider(
          create: (context) => RevenueController(),
          child: const RevenueReportScreen(),
        ),
      ),
    );
  }
}
