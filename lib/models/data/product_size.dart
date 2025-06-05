class ProductSize {
  final int productId;
  final int sizeId;

  ProductSize({
    required this.productId,
    required this.sizeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'sizeId': sizeId,
    };
  }

  factory ProductSize.fromMap(Map<String, dynamic> map) {
    return ProductSize(
      productId: map['productId'],
      sizeId: map['sizeId'],
    );
  }
}
