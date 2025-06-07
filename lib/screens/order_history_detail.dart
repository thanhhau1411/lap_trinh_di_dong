import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:watchstore/controllers/order_controller.dart';
import 'package:watchstore/controllers/product_controller.dart';
import 'package:watchstore/models/data/order.dart';
import 'package:watchstore/models/data/order_detail.dart';
import 'package:watchstore/models/data/product.dart';

class OrderHistoryDetailScreen extends StatefulWidget {
  final Order order;

  const OrderHistoryDetailScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderHistoryDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderHistoryDetailScreen> {
  List<OrderDetail> orderDetails = [];
  Map<int, Product> productMap = {};
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    _loadOrderDetails();
    super.didChangeDependencies();
  }

  Future<void> _loadOrderDetails() async {
    final _productControl = await context.read<ProductController>();
    setState(() => isLoading = true);
    
    try {
      orderDetails = await context.read<OrderController>().getOrderDetailByOrderId(widget.order.id!);

      // Load thông tin sản phẩm
      for (var detail in orderDetails) {
        Product? product = await _productControl.getProductById(detail.productId);
        productMap[detail.productId] = product ?? Product(name: 'Default', description: 'Default', price: -1, quantity: -1, imageUrl: 'Default', brandId: -1);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải chi tiết đơn hàng: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    setState(() => isLoading = false);
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
        title: Text(
          'Đơn hàng #${widget.order.id}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _shareOrder(),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadOrderDetails,
              color: Colors.deepPurple,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderStatusCard(),
                    const SizedBox(height: 16),
                    _buildOrderInfoCard(),
                    const SizedBox(height: 16),
                    _buildProductsCard(),
                    const SizedBox(height: 16),
                    _buildPriceBreakdownCard(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOrderStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.order.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              _getStatusIcon(widget.order.status),
              size: 40,
              color: _getStatusColor(widget.order.status),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.order.status ?? 'Không xác định',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getStatusColor(widget.order.status),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStatusMessage(widget.order.status),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getStatusMessage(String? status) {
    switch (status) {
      case 'Đã giao':
        return 'Đơn hàng của bạn đã được giao thành công';
      case 'Đang xử lý':
        return 'Đơn hàng đang được chuẩn bị và xử lý';
      case 'Đã hủy':
        return 'Đơn hàng đã bị hủy';
      default:
        return 'Trạng thái đơn hàng không xác định';
    }
  }

  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.deepPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Thông tin đơn hàng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.receipt_long,
            label: 'Mã đơn hàng',
            value: '#${widget.order.id}',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'Ngày đặt hàng',
            value: DateFormat('dd/MM/yyyy - HH:mm').format(widget.order.orderDate),
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.local_shipping,
            label: 'Ngày giao hàng',
            value: DateFormat('dd/MM/yyyy - HH:mm').format(widget.order.deliveryDate),
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.person,
            label: 'Mã khách hàng',
            value: '#${widget.order.customerId}',
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_bag,
                color: Colors.deepPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Sản phẩm đã mua',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${orderDetails.length} sản phẩm',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...orderDetails.map((detail) => _buildProductItem(detail)).toList(),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderDetail detail) {
    final product = productMap[detail.productId];
    if (product == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[300],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.watch,
                    color: Colors.grey[600],
                    size: 30,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Số lượng: ${detail.quantity}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${NumberFormat('#,###').format(detail.productPrice)} đ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
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

  Widget _buildPriceBreakdownCard() {
    double subtotal = orderDetails.fold(0, (sum, detail) => 
        sum + ((detail.productPrice ?? 0) * (detail.quantity ?? 0)));
    double shipping = 0; // Phí ship cố định
    double discount = 0; // Giảm giá
    double total = widget.order.totalPrice ?? subtotal + shipping - discount;

    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt,
                color: Colors.deepPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Chi tiết thanh toán',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPriceRow('Tạm tính', subtotal),
          const SizedBox(height: 8),
          if(shipping > 0)
            _buildPriceRow('Phí vận chuyển', shipping),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow('Giảm giá', -discount, isDiscount: true),
          ],
          const Divider(height: 24),
          _buildPriceRow('Tổng cộng', total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.deepPurple : Colors.grey[700],
          ),
        ),
        Text(
          '${isDiscount ? '-' : ''}${NumberFormat('#,###').format(amount.abs())} đ',
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal 
                ? Colors.deepPurple 
                : isDiscount 
                    ? Colors.green 
                    : Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (widget.order.status == 'Đang xử lý')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _cancelOrder(),
              icon: const Icon(Icons.cancel),
              label: const Text('Hủy đơn hàng'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        
        if (widget.order.status == 'Đã giao') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _reorder(),
              icon: const Icon(Icons.refresh),
              label: const Text('Đặt lại đơn hàng'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _writeReview(),
              icon: const Icon(Icons.star_rate),
              label: const Text('Đánh giá sản phẩm'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                side: const BorderSide(color: Colors.deepPurple),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
        
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _contactSupport(),
            icon: const Icon(Icons.support_agent),
            label: const Text('Liên hệ hỗ trợ'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _shareOrder() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chia sẻ đơn hàng...'),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _cancelOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn hàng'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cancel order logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đơn hàng đã được hủy thành công'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hủy đơn hàng', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _reorder() {
    // TODO: Implement reorder logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang thêm sản phẩm vào giỏ hàng...'),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _writeReview() {
    // TODO: Navigate to review screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chuyển đến trang đánh giá...'),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _contactSupport() {
    // TODO: Navigate to support screen or open contact
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang kết nối với bộ phận hỗ trợ...'),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}