class WarrantyCard {
  final int? id;               // Mã phiếu bảo hành
  final int orderDetail;      // mã chi tiết đơn
  final DateTime issuedDate;     // Ngày cấp
  final DateTime expiryDate;     // Ngày hết hạn
  final String? notes;           // Ghi chú thêm

  WarrantyCard({
    this.id,
    required this.orderDetail,
    required this.issuedDate,
    required this.expiryDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderDetail': orderDetail,
      'issuedDate': issuedDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory WarrantyCard.fromMap(Map<String, dynamic> map) {
    return WarrantyCard(
      id: map['id'],
      orderDetail: map['orderDetail'],
      issuedDate: DateTime.parse(map['issuedDate']),
      expiryDate: DateTime.parse(map['expiryDate']),
      notes: map['notes'],
    );
  }
}
