class WatchAttribute {
  late int? attributeId;
  late String name;
  late String dataType;
  late int quantity;

  WatchAttribute({
    this.attributeId,
    required this.name,
    required this.dataType,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'attributeId': attributeId,
      'name': name,
      'dataType': dataType,
      'quantity': quantity,
    };
  }

  factory WatchAttribute.fromMap(Map<String, dynamic> map) {
    return WatchAttribute(
      attributeId: map['attributeId'],
      name: map['name'],
      dataType: map['dataType'],
      quantity: map['quantity'],
    );
  }
}