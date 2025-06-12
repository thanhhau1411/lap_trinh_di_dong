class ImportReceiptDetail {
  final int? id;
  final int importReceiptId;   // Liên kết đến phiếu nhập
  final int productId;        // Mã đồng hồ
  final int quantity;

  ImportReceiptDetail({
    this.id,
    required this.importReceiptId,
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'importReceiptId': importReceiptId,
      'productId': productId,
      'quantity': quantity,
    };
  }

  factory ImportReceiptDetail.fromMap(Map<String, dynamic> map) {
    return ImportReceiptDetail(
      id: map['id'],
      importReceiptId: map['importReceiptId'],
      productId: map['productId'],
      quantity: map['quantity'],
    );
  }
}
