// lib/screens/revenue_report_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/revenue_controller.dart';
import 'order_list_by_status_screen.dart';

class RevenueReportScreen extends StatefulWidget {
  const RevenueReportScreen({super.key});

  @override
  State<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends State<RevenueReportScreen> {
  @override
  void initState() {
    super.initState();
  }

  // Hàm định dạng tiền tệ (ĐÃ SỬA: Đồng bộ với admin_home.dart)
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
  Widget build(BuildContext context) {
    // Không cần Provider.of ở đây, vì Consumer sẽ cung cấp controller
    // final revenueController = Provider.of<RevenueController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Báo cáo doanh thu',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0078D7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<RevenueController>( // Sử dụng Consumer để truy cập controller
        builder: (context, controller, child) { // 'controller' được định nghĩa ở đây
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Text(
                'Lỗi: ${controller.errorMessage}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Thống kê doanh số tổng quan'),
                const SizedBox(height: 10),
                _buildStatsCard(
                  title: 'Tổng doanh thu',
                  value: _formatCurrency(controller.totalRevenue), // Truyền controller.totalRevenue
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('Thống kê đơn hàng theo trạng thái'),
                const SizedBox(height: 10),
                _buildOrderStatusCard(
                  context: context,
                  successful: controller.successfulOrdersCount, // Truyền controller.successfulOrdersCount
                  cancelled: controller.cancelledOrdersCount,   // Truyền controller.cancelledOrdersCount
                  pending: controller.pendingOrdersCount,     // Truyền controller.pendingOrdersCount
                ),
                const SizedBox(height: 20),
                // Các phần khác của báo cáo có thể thêm vào đây
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard({
    required BuildContext context,
    required int successful,
    required int cancelled,
    required int pending,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderListByStatusScreen(
                      status: 'thành công',
                      title: 'Thành công',
                    ),
                  ),
                );
              },
              child: _buildStatusRow(
                icon: Icons.check_circle,
                status: 'Thành công',
                count: successful,
                color: Colors.green,
              ),
            ),
            const Divider(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderListByStatusScreen(
                      status: 'đang chờ',
                      title: 'Đang chờ',
                    ),
                  ),
                );
              },
              child: _buildStatusRow(
                icon: Icons.pending,
                status: 'Đang chờ',
                count: pending,
                color: Colors.orange,
              ),
            ),
            const Divider(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderListByStatusScreen(
                      status: 'đã hủy',
                      title: 'Đã hủy',
                    ),
                  ),
                );
              },
              child: _buildStatusRow(
                icon: Icons.cancel,
                status: 'Đã hủy',
                count: cancelled,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String status,
    required int count,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              '$status:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ),
          Text(
            '$count đơn hàng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
