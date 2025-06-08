class ProductAttributeValue {
  int? id;
  int productId;
  int attributeId;
  Object value;

  ProductAttributeValue({
    this.id,
    required this.productId,
    required this.attributeId,
    required this.value
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'attributeId': attributeId,
      'value': value
    };
  }

  factory ProductAttributeValue.fromMap(Map<String, dynamic> map) {
    return ProductAttributeValue(
      id: map['id'],
      productId: map['productId'],
      attributeId: map['attributeId'],
      value: map['value']
    );
  }

}