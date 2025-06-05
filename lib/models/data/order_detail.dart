class OrderDetail {
  final int? id;
  final int orderId;
  final int productId; 

  OrderDetail({
    this.id,
    required this.orderId,
    required this.productId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
    };
  }

  factory OrderDetail.fromMap(Map<String, dynamic> map) {
    return OrderDetail(
      id: map['id'],
      orderId: map['orderId'],
      productId: map['productId'],
    );
  }
}
