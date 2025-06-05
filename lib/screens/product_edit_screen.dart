import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Thêm package chọn ảnh
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../controllers/product_controller.dart';

class ProductEditScreen extends StatefulWidget {
  final Product? product;

  const ProductEditScreen({Key? key, this.product}) : super(key: key);

  @override
  _ProductEditScreenState createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _description;
  late double _price;
  late int _quantity;

  File? _imageFile; // Lưu ảnh được chọn

  @override
  void initState() {
    super.initState();
    _name = widget.product?.name ?? '';
    _description = widget.product?.description ?? '';
    _price = widget.product?.price ?? 0.0;
    _quantity = widget.product?.quantity ?? 0;

    // Nếu sản phẩm cũ có ảnh URL, bạn có thể convert thành File hoặc giữ nguyên URL (nếu cần)
    // Ở đây ta không dùng URL nữa nên _imageFile = null
    _imageFile = null;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Nếu dùng File ảnh thì bạn cần xử lý upload ảnh hoặc lưu đường dẫn file trong local storage
      // Ở đây tạm thời lưu đường dẫn file ảnh trong imageUrl (có thể thay đổi tùy cách bạn xử lý ảnh)
      final imageUrl = _imageFile?.path ?? widget.product?.imageUrl ?? '';

      final product = Product(
        id: widget.product?.id ?? DateTime.now().toString(),
        name: _name,
        description: _description,
        price: _price,
        quantity: _quantity,
        imageUrl: imageUrl,
      );

      final productController = Provider.of<ProductController>(
        context,
        listen: false,
      );

      if (widget.product == null) {
        productController.addProduct(product);
      } else {
        productController.updateProduct(product);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                validator:
                    (val) =>
                        val == null || val.isEmpty ? 'Vui lòng nhập tên' : null,
                onSaved: (val) => _name = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 3,
                onSaved: (val) => _description = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _price == 0.0 ? '' : _price.toString(),
                decoration: const InputDecoration(labelText: 'Giá'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Vui lòng nhập giá';
                  }
                  if (double.tryParse(val) == null) {
                    return 'Giá không hợp lệ';
                  }
                  if (double.parse(val) <= 0) {
                    return 'Giá phải lớn hơn 0';
                  }
                  return null;
                },
                onSaved: (val) => _price = double.parse(val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _quantity == 0 ? '' : _quantity.toString(),
                decoration: const InputDecoration(
                  labelText: 'Số lượng tồn kho',
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Vui lòng nhập số lượng';
                  }
                  if (int.tryParse(val) == null) {
                    return 'Số lượng không hợp lệ';
                  }
                  if (int.parse(val) < 0) {
                    return 'Số lượng không được âm';
                  }
                  return null;
                },
                onSaved: (val) => _quantity = int.parse(val!),
              ),
              const SizedBox(height: 16),

              // Nút chọn ảnh từ thiết bị
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Chọn ảnh sản phẩm'),
              ),

              const SizedBox(height: 16),

              // Preview ảnh nếu có
              if (_imageFile != null)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                  ),
                )
              else if (widget.product?.imageUrl != null &&
                  widget.product!.imageUrl.isNotEmpty)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.product!.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.red),
                              Text('Không thể tải hình ảnh'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
