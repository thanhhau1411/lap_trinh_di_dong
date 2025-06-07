import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchstore/controllers/auth_controller.dart';
import 'package:watchstore/controllers/customer_controller.dart';
import 'package:watchstore/controllers/order_controller.dart';
import 'package:watchstore/controllers/product_controller.dart';
import 'package:watchstore/models/data/order.dart';
import 'package:watchstore/models/data/order_detail.dart';
import 'package:watchstore/models/data/orderdetail_attributeId.dart';
import 'package:watchstore/models/data/product.dart';
import 'package:watchstore/models/data/product_attribute_value.dart';
import 'package:watchstore/models/data/watch_attribute.dart';
import 'package:watchstore/screens/login_screen.dart';
import 'package:watchstore/screens/order_result_screen.dart';
import 'package:watchstore/screens/user_profile_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Product product;
  final List<WatchAttribute> attributes;

  const CheckoutScreen({
    Key? key,
    required this.product,
    required this.attributes,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int quantity = 1;
  late double totalPrice;
  List<ProductAttributeValue>? allValues;
  late ProductController productController;
  // Lưu lựa chọn hiện tại cho mỗi attributeId
  final Map<int, ProductAttributeValue?> selectedAttributeValues = {};

  // Lưu danh sách các lựa chọn có thể có cho mỗi attributeId
  final Map<int, List<ProductAttributeValue>> attributeOptions = {};

  @override
  void initState() {
    super.initState();
    totalPrice = widget.product.price;
    for (var attr in widget.attributes) {
      selectedAttributeValues[attr.attributeId!] =
          null; // Không chọn gì lúc đầu
      attributeOptions[attr.attributeId!] =
          []; // Danh sách ProductAttributeValue
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAttributeValues();
  }

  Future<void> _loadAttributeValues() async {
    productController = context.read<ProductController>();
    final productId = widget.product.id!;
    allValues = await productController.getAllAttributeValues(productId);

    setState(() {
      for (var attr in widget.attributes) {
        int attrId = attr.attributeId!;
        final filtered =
            (allValues ?? [])
                .where(
                  (e) => e.productId == productId && e.attributeId == attrId,
                )
                .toList();

        attributeOptions[attrId] = filtered;
        if (filtered.isNotEmpty) {
          selectedAttributeValues[attrId] = filtered.first;
        } else {
          selectedAttributeValues[attrId] = null;
        }
      }
    });
  }

  void _updateTotalPrice() {
    setState(() {
      totalPrice = widget.product.price * quantity;
    });
  }

  void _onCheckout() async {
    final orderController = context.read<OrderController>();
    final authController = context.read<AuthController>();

    final customerId = authController.customerInfo?.id;
    if (customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập trước khi đặt hàng')),
      );
      return;
    }

    final customerAddress = authController.customerInfo?.address;
    if(customerAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đặt địa chỉ giao hàng trước khi thanh toán')),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
      return;
    }

    final newOrder = Order(
      orderDate: DateTime.now(),
      deliveryDate: DateTime.now().add(const Duration(days: 2)),
      status: 'Đã giao',
      customerId: customerId,
      totalPrice: totalPrice,
    );

    List<OrderDetail> orderDetails = [];
    OrderDetailAttributeId? oDAttribute = null;
    for (var entry in selectedAttributeValues.entries) {
      final attributeId = entry.key;
      final pav = entry.value;
      if (pav != null) {
        oDAttribute = OrderDetailAttributeId(orderDetailId: 0, attributeId: attributeId, attributeValueId: pav.id!);
      }
    }
     orderDetails.add(
          OrderDetail(
            orderId: 0, // sẽ gán trong controller
            productId: widget.product.id!,
            quantity: quantity,
            productPrice: widget.product.price,
            orderDetailAttributeId: [oDAttribute!]
          ),
        );
    // Nếu không có thuộc tính nào được chọn, vẫn thêm đơn hàng đơn giản
    if (selectedAttributeValues.isEmpty) {
      orderDetails.add(OrderDetail(orderId: 0, productId: widget.product.id!));
    }
    await orderController.addOrder(newOrder, orderDetails);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => OrderResultScreen(
              totalAmount: totalPrice,
              order: newOrder,
              orderDetails: orderDetails,
              product: widget.product,
              productAttribute: selectedAttributeValues.map((key, value) {
                final attr = widget.attributes.firstWhere(
                  (a) => a.attributeId == key,
                  orElse:
                      () => throw Exception('Attribute not found for id $key'),
                );
                return MapEntry(attr, value!);
              }),
            ),
      ),
    );
  }

  Widget _buildAttributeDropdown(WatchAttribute attribute) {
    int attrId = attribute.attributeId!;
    List<ProductAttributeValue> values = attributeOptions[attrId] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${attribute.name}:',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ProductAttributeValue>(
              isExpanded: true,
              value: selectedAttributeValues[attrId],
              hint: Text('Chọn ${attribute.name}'),
              items:
                  values.map((item) {
                    return DropdownMenuItem<ProductAttributeValue>(
                      value: item,
                      child: Text(item.value.toString() ?? '-1'),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedAttributeValues[attrId] = value;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final seenIds = <int>{};
    final uniqueAttributes =
        widget.attributes.where((attr) {
          final isNew = !seenIds.contains(attr.attributeId);
          if (isNew) seenIds.add(attr.attributeId!);
          return isNew;
        }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Thông tin sản phẩm
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.product.imageUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${widget.product.price.toStringAsFixed(0)} \$',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red.shade400,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Dropdown thuộc tính
                ...uniqueAttributes.map(_buildAttributeDropdown),

                const SizedBox(height: 8),

                // Số lượng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Số lượng:', style: TextStyle(fontSize: 16)),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed:
                                quantity > 1
                                    ? () {
                                      setState(() {
                                        quantity--;
                                        _updateTotalPrice();
                                      });
                                    }
                                    : null,
                          ),
                          Text(
                            '$quantity',
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                quantity++;
                                _updateTotalPrice();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Tổng tiền
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng tiền:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${totalPrice.toStringAsFixed(0)} \$',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // Nút xác nhận
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _onCheckout();
                },
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text(
                  'Xác nhận thanh toán',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
