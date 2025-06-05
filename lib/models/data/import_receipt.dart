class ImportReceipt {
  final int? id;                 // Mã phiếu nhập
  final DateTime importDate;       // Ngày nhập
  final String supplierName;       // Tên nhà cung cấp
  final String staffName;          // Nhân viên thực hiện
  final String? notes;             // Ghi chú

  ImportReceipt({
    this.id,
    required this.importDate,
    required this.supplierName,
    required this.staffName,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'importDate': importDate.toIso8601String(),
      'supplierName': supplierName,
      'staffName': staffName,
      'notes': notes,
    };
  }

  factory ImportReceipt.fromMap(Map<String, dynamic> map) {
    return ImportReceipt(
      id: map['id'],
      importDate: DateTime.parse(map['importDate']),
      supplierName: map['supplierName'],
      staffName: map['staffName'],
      notes: map['notes'],
    );
  }
}
