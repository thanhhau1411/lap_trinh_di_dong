import 'package:flutter/material.dart';
import 'package:watchstore/models/data/database_helper.dart';
import 'package:watchstore/models/data/product.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _imageUrlController = TextEditingController(text: widget.product.imageUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    final dbHelper = DatabaseHelper();

    final updatedProduct = {
      'name': _nameController.text,
      'description': _descController.text,
      'price': double.tryParse(_priceController.text) ?? 0,
      'imageUrl': _imageUrlController.text,
      // quantity không sửa ở đây
      // brandId không sửa ở đây (nếu muốn sửa thì bổ sung)
    };

    final db = await DatabaseHelper.database;
    await db.update(
      'Product',
      updatedProduct,
      where: 'id = ?',
      whereArgs: [widget.product.id],
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chỉnh sửa sản phẩm')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Tên sản phẩm'),
            ),
            TextField(
              controller: _descController,
              decoration: InputDecoration(labelText: 'Mô tả'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Giá (VNĐ)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(labelText: 'Đường dẫn ảnh'),
            ),
            SizedBox(height: 20),
            // Hiển thị số lượng hiện tại không cho sửa
            Text(
              'Số lượng hiện tại: ${widget.product.quantity}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _saveProduct, child: Text('Lưu')),
          ],
        ),
      ),
    );
  }
}
