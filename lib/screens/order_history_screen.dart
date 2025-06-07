import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:watchstore/controllers/order_controller.dart';
import 'package:watchstore/models/data/order.dart';
import 'package:watchstore/screens/order_history_detail.dart';


class OrderHistoryScreen extends StatefulWidget {
  final int customerId;
  
  const OrderHistoryScreen({
    Key? key,
    required this.customerId,
  }) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> orders = [];
  List<String> statusFilter = ['Tất cả', 'Đang xử lý', 'Đã giao', 'Đã hủy'];
  String selectedStatus = 'Tất cả';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadOrders();
  }
  Future<void> _loadOrders() async {
    setState(() => isLoading = true);
    
    // Dữ liệu mẫu
    orders = await context.read<OrderController>().getOrderByCustomer(widget.customerId);
    
    setState(() => isLoading = false);
  }

  List<Order> get filteredOrders {
    if (selectedStatus == 'Tất cả') {
      return orders;
    }
    return orders.where((order) => order.status == selectedStatus).toList();
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Đã giao':
        return Colors.green;
      case 'Đang xử lý':
        return Colors.orange;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'Đã giao':
        return Icons.check_circle;
      case 'Đang xử lý':
        return Icons.schedule;
      case 'Đã hủy':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Lịch sử mua hàng',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list, color: Colors.deepPurple),
                const SizedBox(width: 8),
                const Text(
                  'Lọc theo trạng thái:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: statusFilter.map((status) {
                        bool isSelected = selectedStatus == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                selectedStatus = status;
                              });
                            },
                            selectedColor: Colors.deepPurple.withOpacity(0.2),
                            checkmarkColor: Colors.deepPurple,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Orders List
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                    ),
                  )
                : filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        color: Colors.deepPurple,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            return _buildOrderCard(filteredOrders[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Không có đơn hàng nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thực hiện mua hàng đầu tiên của bạn!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: Colors.deepPurple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Đơn hàng #${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(order.status).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(order.status),
                        size: 16,
                        color: _getStatusColor(order.status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.status ?? 'Không xác định',
                        style: TextStyle(
                          color: _getStatusColor(order.status),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Order Info
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.calendar_today,
                        label: 'Ngày đặt',
                        value: DateFormat('dd/MM/yyyy').format(order.orderDate),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.local_shipping,
                        label: 'Ngày giao',
                        value: DateFormat('dd/MM/yyyy').format(order.deliveryDate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Total Price
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: Colors.green[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tổng tiền:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${NumberFormat('#,###').format(order.totalPrice ?? 0)} đ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewOrderDetails(order),
                        icon: const Icon(Icons.visibility),
                        label: const Text('Xem chi tiết'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          side: const BorderSide(color: Colors.deepPurple),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (order.status == 'Đã giao')
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _reorder(order),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Đặt lại'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _viewOrderDetails(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(create: (context) => OrderController(),child: OrderHistoryDetailScreen(order: order)),
      ),
    );
  }

  void _reorder(Order order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang thêm lại sản phẩm từ đơn hàng #${order.id} vào giỏ hàng...'),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
    // TODO: Implement reorder logic
  }
}
