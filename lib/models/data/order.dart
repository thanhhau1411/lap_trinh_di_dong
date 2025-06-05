class Order {
  final int id;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final String? status;
  final int customerId;

  Order({
    required this.id,
    required this.orderDate,
    required this.deliveryDate,
    this.status,
    required this.customerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate.toIso8601String(),
      'status': status,
      'customerId': customerId,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      orderDate: DateTime.parse(map['orderDate']),
      deliveryDate: DateTime.parse(map['deliveryDate']),
      status: map['status'],
      customerId: map['customerId'],
    );
  }
}
