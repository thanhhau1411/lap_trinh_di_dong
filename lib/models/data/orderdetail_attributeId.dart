class OrderDetailAttributeId {
  int? id;
  late int orderDetailId;
  late int attributeId;
  late int attributeValueId;

  OrderDetailAttributeId({
    this.id,
    required this.orderDetailId,
    required this.attributeId,
    required this.attributeValueId,
  });

  // Chuyển từ object thành map để insert/update DB
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'orderDetailId': orderDetailId,
      'attributeId': attributeId,
      'attributeValueId': attributeValueId,
    };
    return map;
  }

  // Tạo object từ map lấy từ DB
  factory OrderDetailAttributeId.fromMap(Map<String, dynamic> map) {
    return OrderDetailAttributeId(
      id: map['id'],
      orderDetailId: map['orderDetailId'],
      attributeId: map['attributeId'],
      attributeValueId: map['attributeValueId'],
    );
  }
}
