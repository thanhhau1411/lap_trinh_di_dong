import 'package:watchstore/models/data/orderdetail_attributeId.dart';

class OrderDetail {
  int? id;
  int orderId;
  int productId; 
  int? quantity;
  double? productPrice;
  late List<OrderDetailAttributeId>? orderDetailAttributeId;
  
  OrderDetail({
    this.id,
    required this.orderId,
    required this.productId,
    this.quantity,
    this.productPrice,
    this.orderDetailAttributeId
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'quantity': quantity,
      'productPrice': productPrice
    };
  }

  factory OrderDetail.fromMap(Map<String, dynamic> map) {
    return OrderDetail(
      id: map['id'],
      orderId: map['orderId'],
      productId: map['productId'],
      quantity: map['quantity'],
      productPrice: map['productPrice']
    );
  }
}
