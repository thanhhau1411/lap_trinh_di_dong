import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:watchstore/models/data/brand.dart';
import 'package:watchstore/models/data/database_helper.dart';

class AddProductPage extends StatefulWidget {
  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  int _quantity = 0; // mặc định 0, không cho nhập

  List<Brand> _brands = [];
  Brand? _selectedBrand;

  String? _imagePath;

  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    try {
      final dbHelper = DatabaseHelper();
      final brandMaps = await dbHelper.getBrandsRaw();

      final brands = brandMaps.map((e) => Brand.fromMap(e)).toList();

      setState(() {
        _brands = brands;
        if (_brands.isNotEmpty) _selectedBrand = _brands[0];
        _isLoading = false;
      });
    } catch (e) {
      // Nếu lỗi thì hiển thị lỗi hoặc empty
      setState(() {
        _brands = [];
        _selectedBrand = null;
        _isLoading = false;
      });
      print('Lỗi load brand: $e');
    }
  }

  void _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Lấy tên ảnh từ đường dẫn
      String fileName = path.basename(image.path);

      setState(() {
        _imagePath = fileName; // Lưu tên ảnh thôi, không phải đường dẫn đầy đủ
      });
    }
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBrand == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Vui lòng chọn thương hiệu')));
        return;
      }

      try {
        final dbHelper = DatabaseHelper();
        await dbHelper.insertProduct(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          price: double.parse(_priceController.text),
          quantity: _quantity, // mặc định 0
          imageUrl: _imagePath ?? '', // Có thể xử lý lưu file ảnh nếu cần
          brandId: _selectedBrand!.id!,
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Thêm sản phẩm thành công')));

        Navigator.pop(context);
      } catch (e) {
        print('Lỗi lưu sản phẩm: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi lưu sản phẩm')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thêm sản phẩm mới')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : (_brands.isEmpty
                    ? Center(child: Text('Không có thương hiệu nào'))
                    : Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Tên sản phẩm',
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Nhập tên sản phẩm'
                                        : null,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _descController,
                            decoration: InputDecoration(labelText: 'Mô tả'),
                            maxLines: 3,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(labelText: 'Giá cả'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Nhập giá cả';
                              final n = num.tryParse(value);
                              if (n == null) return 'Giá không hợp lệ';
                              if (n <= 0) return 'Giá phải lớn hơn 0';
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Số lượng'),
                            initialValue: '0',
                            enabled: false,
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              _imagePath == null
                                  ? Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.image,
                                      size: 50,
                                      color: Colors.grey[600],
                                    ),
                                  )
                                  : Image.file(
                                    File(_imagePath!),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                              SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: _pickImage,
                                child: Text('Chọn ảnh sản phẩm'),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<Brand>(
                            value: _selectedBrand,
                            items:
                                _brands
                                    .map(
                                      (brand) => DropdownMenuItem(
                                        value: brand,
                                        child: Text(brand.name),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBrand = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Chọn thương hiệu',
                            ),
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Vui lòng chọn thương hiệu'
                                        : null,
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _saveProduct,
                            child: Text('Lưu sản phẩm'),
                          ),
                        ],
                      ),
                    )),
      ),
    );
  }
}
