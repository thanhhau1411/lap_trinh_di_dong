// lib/screens/order_list_by_status_screen.dart
import 'package:flutter/material.dart';
import 'package:watchstore/models/data/database_helper.dart';
import 'package:watchstore/models/data/order.dart';


class OrderListByStatusScreen extends StatefulWidget {
  final String status;
  final String title;

  const OrderListByStatusScreen({
    super.key,
    required this.status,
    required this.title,
  });

  @override
  State<OrderListByStatusScreen> createState() => _OrderListByStatusScreenState();
}

class _OrderListByStatusScreenState extends State<OrderListByStatusScreen> {
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrdersByStatus();
  }

  Future<List<Order>> _fetchOrdersByStatus() async {
    final dbHelper = DatabaseHelper();
    // Hàm này sẽ sử dụng `widget.status` (ví dụ: 'thành công') để truy vấn
    return await dbHelper.getOrdersByStatus(widget.status);
  }

  // Hàm định dạng tiền tệ (được sao chép từ admin_home.dart và revenue_report_screen.dart)
  String _formatCurrency(double amount) {
    if (amount >= 1000000000) { // Tỷ
      return '${(amount / 1000000000).toStringAsFixed(1)}Bvnd';
    } else if (amount >= 1000000) { // Triệu
      return '${(amount / 1000000).toStringAsFixed(1)}Mvnd';
    } else { // Dưới 1 triệu, hiển thị đầy đủ với 2 chữ số thập phân
      return '${amount.toStringAsFixed(2)}vnd';
    }
  }

  // Hàm chuyển đổi trạng thái sang tiếng Việt (đã có sẵn)
  String _mapStatusToVietnamese(String? status) {
    switch (status) {
      case 'thành công': 
        return 'Thành công';
      case 'đang chờ': 
        return 'Đang chờ';
      case 'đã hủy': 
        return 'Đã hủy';
      default:
        return status ?? 'Không xác định';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Đơn hàng ${widget.title}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0078D7),
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Không có đơn hàng nào với trạng thái này.'),
            );
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mã đơn hàng: #${order.id}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Ngày đặt: ${order.orderDate.toLocal().toString().split(' ')[0]}'),
                        Text('Ngày giao: ${order.deliveryDate.toLocal().toString().split(' ')[0]}'),
                        Text('Trạng thái: ${_mapStatusToVietnamese(order.status)}'), // Sử dụng hàm chuyển đổi
                        // ĐÃ SỬA: Áp dụng hàm _formatCurrency cho totalPrice
                        Text('Tổng giá: ${_formatCurrency(order.totalPrice ?? 0.0)}'), 
                        Text('ID Khách hàng: ${order.customerId}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
