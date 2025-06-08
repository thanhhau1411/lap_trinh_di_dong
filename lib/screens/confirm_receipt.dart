import 'package:flutter/material.dart';
import 'package:watchstore/models/data/database_helper.dart';
import 'package:watchstore/models/data/import_receipt.dart';
import 'package:watchstore/models/data/product.dart';
import 'package:intl/intl.dart';

class ConfirmStockInScreen extends StatefulWidget {
  final List<Map<String, dynamic>> itemsWithDetails;

  ConfirmStockInScreen({required this.itemsWithDetails});

  @override
  _ConfirmStockInScreenState createState() => _ConfirmStockInScreenState();
}

class _ConfirmStockInScreenState extends State<ConfirmStockInScreen> {
  final _supplierController = TextEditingController();
  final _staffController = TextEditingController();
  final _notesController = TextEditingController();

  double get totalPrice {
    double total = 0;
    for (var item in widget.itemsWithDetails) {
      total += (item['quantity'] as int) * (item['importPrice'] as double);
    }
    return total;
  }

  Future<void> _saveImportReceipt() async {
    final receipt = ImportReceipt(
      importDate: DateTime.now(),
      supplierName: _supplierController.text.trim(),
      staffName: _staffController.text.trim(),
      notes: _notesController.text.trim(),
    );

    final dbHelper = DatabaseHelper();

    // 1. Lưu phiếu nhập
    final receiptId = await dbHelper.insertImportReceipt(receipt);

    // 2. Lưu chi tiết và cập nhật tồn kho - chạy đồng thời bằng Future.wait
    final futures = widget.itemsWithDetails.map((item) async {
      final product = item['product'] as Product;
      final quantity = item['quantity'] as int;

      await dbHelper.insertImportReceiptDetail(
        receiptId,
        product.id!,
        quantity,
      );
      await dbHelper.updateProductQuantity(product.id!, quantity);
    });

    await Future.wait(futures);

    // 3. Thông báo và chuyển màn hình
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Đã lưu phiếu nhập!')));

    await Future.delayed(Duration(seconds: 1));

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  void dispose() {
    _supplierController.dispose();
    _staffController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('dd/MM/yyyy').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: Text('Xác nhận phiếu nhập')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ngày nhập: $dateFormatted'),
            TextField(
              controller: _supplierController,
              decoration: InputDecoration(labelText: 'Tên nhà cung cấp'),
            ),
            TextField(
              controller: _staffController,
              decoration: InputDecoration(labelText: 'Tên nhân viên'),
            ),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: 'Ghi chú (tùy chọn)'),
            ),
            SizedBox(height: 20),
            Text(
              'Chi tiết sản phẩm:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.itemsWithDetails.length,
                itemBuilder: (context, index) {
                  final item = widget.itemsWithDetails[index];
                  final product = item['product'] as Product;
                  final quantity = item['quantity'] as int;
                  final importPrice = item['importPrice'] as double;
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                      'Số lượng: $quantity, Giá: ${importPrice.toStringAsFixed(0)}₫',
                    ),
                    trailing: Text(
                      'Thành tiền: ${(quantity * importPrice).toStringAsFixed(0)}₫',
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Tổng tiền: ${totalPrice.toStringAsFixed(0)}₫',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _saveImportReceipt,
                child: Text('Xác nhận nhập'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
