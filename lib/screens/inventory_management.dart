import 'package:flutter/material.dart';
import 'package:watchstore/controllers/product_controller.dart';
import 'package:watchstore/models/data/database_helper.dart';
import 'package:watchstore/models/data/product.dart';
import 'package:watchstore/screens/add_product.dart';
import 'package:watchstore/screens/edit_product.dart';
import 'package:watchstore/screens/receipt.dart';

class InventoryManagementScreen extends StatefulWidget {
  @override
  _InventoryManagementScreenState createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  String searchQuery = '';
  String countToday = '0';
  String countWeek = '0';
  String countMonth = '0';

  List<Product> products = [];
  List<String> brandNames = [];

  Future<void> loadProducts() async {
    final results = await _databaseHelper.getProductsWithBrand();
    setState(() {
      products = results.map((map) => Product.fromMap(map)).toList();
      brandNames = results.map((map) => map['brandName'] as String).toList();
    });
  }

  void loadStats() async {
    final stats = await _databaseHelper.getImportReceiptStats();

    setState(() {
      countToday = stats['today'].toString();
      countWeek = stats['week'].toString();
      countMonth = stats['month'].toString();
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProducts();
    loadProducts();
    loadStats();
  }

  Future<void> _loadProducts() async {
    final data = await getProducts();
    setState(() {
      products = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Quản lý kho',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.notifications_rounded,
              color: Color(0xFF64748B),
              size: 20,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(height: 1, color: Color(0xFFF1F5F9)),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.white,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                hintStyle: TextStyle(color: Color(0xFF64748B)),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Color(0xFF64748B),
                ),
                filled: true,
                fillColor: Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Color(0xFF667EEA),
              unselectedLabelColor: Color(0xFF64748B),
              indicatorColor: Color(0xFF667EEA),
              indicatorWeight: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: [
                Tab(text: 'Sản phẩm'),
                Tab(text: 'Nhập kho'),
                Tab(text: 'Phiếu nhập'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(),
                _buildStockInTab(),
                _buildStockEntriesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductPage()),
          );
        },

        backgroundColor: Color(0xFF667EEA),
        icon: Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Thêm sản phẩm',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Products Tab
  Widget _buildProductsTab() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row code ...
          SizedBox(height: 20),

          // Product List
          Expanded(
            child:
                products.isEmpty
                    ? Center(child: Text('Không có sản phẩm'))
                    : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Product Image or Icon
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child:
                                    product.imageUrl.isNotEmpty
                                        ? Image.asset(
                                          'assets/products/${product.imageUrl}',
                                          fit: BoxFit.cover,
                                        )
                                        : Center(
                                          child: Text(
                                            '🕰️',
                                            style: TextStyle(fontSize: 24),
                                          ),
                                        ),
                              ),
                              SizedBox(width: 12),

                              // Product Info + Buttons
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    SizedBox(height: 4),

                                    // Thêm brand với khung viền xanh
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      child: Text(
                                        'Thương hiệu: ${brandNames[index]}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.deepOrangeAccent
                                              .withOpacity(0.8),
                                          shadows: [
                                            Shadow(
                                              offset: Offset(0.3, 0.3),
                                              blurRadius: 0.8,
                                              color: Colors.deepOrange.shade700
                                                  .withOpacity(0.4),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 4),
                                    Text(
                                      product.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          '${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")}₫',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                        Spacer(),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                product.quantity == 0
                                                    ? Color(
                                                      0xFFEF4444,
                                                    ).withOpacity(0.1)
                                                    : product.quantity < 5
                                                    ? Color(
                                                      0xFFF59E0B,
                                                    ).withOpacity(0.1)
                                                    : Color(
                                                      0xFF10B981,
                                                    ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            'Tồn: ${product.quantity}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  product.quantity == 0
                                                      ? Color(0xFFEF4444)
                                                      : product.quantity < 5
                                                      ? Color(0xFFF59E0B)
                                                      : Color(0xFF10B981),
                                            ),
                                          ),
                                        ),

                                        // Nút chỉnh sửa
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        EditProductScreen(
                                                          product: product,
                                                        ),
                                              ),
                                            );

                                            if (result == true) {
                                              setState(() {
                                                // Reload hoặc cập nhật lại danh sách
                                              });
                                            }
                                          },
                                        ),

                                        // Nút xóa
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            final confirm = await showDialog<
                                              bool
                                            >(
                                              context: context,
                                              builder:
                                                  (context) => AlertDialog(
                                                    title: Text('Xác nhận'),
                                                    content: Text(
                                                      'Bạn có chắc chắn muốn xóa sản phẩm này không?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.of(
                                                              context,
                                                            ).pop(false),
                                                        child: Text('Hủy'),
                                                      ),
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.of(
                                                              context,
                                                            ).pop(true),
                                                        child: Text('Xóa'),
                                                      ),
                                                    ],
                                                  ),
                                            );

                                            if (confirm == true) {
                                              final dbHelper = DatabaseHelper();

                                              if (product.id != null) {
                                                int rowsDeleted = await dbHelper
                                                    .deleteProduct(product.id!);

                                                if (rowsDeleted > 0) {
                                                  print(
                                                    'Đã xóa sản phẩm id: ${product.id}',
                                                  );
                                                  setState(() {
                                                    products.removeAt(index);
                                                  });
                                                } else {
                                                  print(
                                                    'Xóa sản phẩm thất bại',
                                                  );
                                                }
                                              } else {
                                                print(
                                                  'ID sản phẩm bị null, không thể xóa',
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // Stock In Tab
  Widget _buildStockInTab() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Stock Entry Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.add_box_rounded, color: Colors.white, size: 48),
                SizedBox(height: 12),
                Text(
                  'Tạo phiếu nhập kho',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Nhập hàng mới vào kho',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StockInScreen(products: []),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF667EEA),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Tạo phiếu nhập',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Quick Stats
          Text(
            'Thống kê nhập kho',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatsCard(
                  'Hôm nay',
                  countToday,
                  Icons.today_rounded,
                  Color(0xFF10B981),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatsCard(
                  'Tuần này',
                  countWeek,
                  Icons.date_range_rounded,
                  Color(0xFF3B82F6),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatsCard(
                  'Tháng này',
                  countMonth,
                  Icons.calendar_month_rounded,
                  Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStockEntriesTab() {
    final DatabaseHelper _databaseHelper = DatabaseHelper();

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        color: Color(0xFF64748B),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Tất cả phiếu',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFF1F5F9)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.date_range_rounded,
                      color: Color(0xFF64748B),
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Tháng này',
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Stock Entries List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _databaseHelper.getAllImportReceiptsWithStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi khi tải dữ liệu'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Không có phiếu nhập nào'));
                }

                final receipts = snapshot.data!;
                return ListView.builder(
                  itemCount: receipts.length,
                  itemBuilder: (context, index) {
                    final receipt = receipts[index];
                    final receiptId = receipt['id'];
                    final dateStr = receipt['importDate'];
                    final supplier = receipt['supplierName'];
                    final productCount = receipt['productCount'] ?? 0;
                    final totalAmount =
                        (receipt['totalAmount'] ?? 0.0) as double;

                    return GestureDetector(
                      onTap: () => _showStockEntryDetail(receipt['id']),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF3B82F6).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.receipt_long_rounded,
                                    color: Color(0xFF3B82F6),
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Phiếu nhập #NK${receiptId.toString().padLeft(4, '0')}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        '${_formatDate(dateStr)} • $supplier',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF10B981).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Hoàn thành',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Divider(color: Color(0xFFF1F5F9), height: 1),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                _buildInfoChip(
                                  '$productCount sản phẩm',
                                  Icons.inventory_rounded,
                                ),
                                SizedBox(width: 12),
                                _buildInfoChip(
                                  '${(totalAmount / 1000000).toStringAsFixed(1)}M₫',
                                  Icons.attach_money_rounded,
                                ),
                                Spacer(),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF64748B),
                                  size: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildStatsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Color(0xFF64748B)),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Dialog Methods
  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Thêm sản phẩm mới',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Tên sản phẩm',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Danh mục',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Giá bán',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF667EEA),
                ),
                child: Text('Thêm', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  void _showStockEntryDetail(int receiptId) async {
    final receipt = await DatabaseHelper().getReceiptByIdFromDB(receiptId);
    if (receipt == null) return;

    final products = await DatabaseHelper().getProductsByReceiptId(receiptId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: Color(0xFF3B82F6),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phiếu nhập #NK${receipt['id'].toString().padLeft(4, '0')}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              'Chi tiết phiếu nhập kho',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Color(0xFFF1F5F9), height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                'Ngày nhập:',
                                _formatDate(receipt['importDate']),
                              ),
                              SizedBox(height: 8),
                              _buildDetailRow(
                                'Nhà cung cấp:',
                                receipt['supplierName'] ?? 'N/A',
                              ),
                              SizedBox(height: 8),
                              _buildDetailRow(
                                'Người tạo:',
                                receipt['staffName']?.toString() ?? 'Admin',
                              ),
                              SizedBox(height: 8),
                              _buildDetailRow(
                                'Trạng thái:',
                                'Hoàn thành',
                                valueColor: Color(0xFF10B981),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Danh sách sản phẩm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 12),
                        if (products.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];

                              return Container(
                                margin: EdgeInsets.only(bottom: 12),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Color(0xFFF1F5F9)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child:
                                          product['imageUrl'] != null &&
                                                  product['imageUrl']
                                                      .toString()
                                                      .isNotEmpty
                                              ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.asset(
                                                  'assets/products/${product['imageUrl']}',
                                                  fit: BoxFit.cover,
                                                  width: 50,
                                                  height: 50,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return Icon(
                                                      Icons.devices,
                                                      size: 20,
                                                    );
                                                  },
                                                ),
                                              )
                                              : Center(
                                                child: Icon(
                                                  Icons.devices,
                                                  size: 20,
                                                ),
                                              ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product['name'] ?? 'N/A',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'SL: ${product['quantity'] ?? 0} • Giá: ${_formatCurrency(product['price'])}₫',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${_formatCurrency(product['total'])}₫',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        else
                          Text(
                            'Không có sản phẩm nào.',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tổng số lượng:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${receipt['productCount'] ?? 0} sản phẩm',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tổng giá trị:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${_formatCurrency(receipt['totalAmount'])}₫',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        if (receipt['note'] != null &&
                            receipt['note'].toString().isNotEmpty) ...[
                          Text(
                            'Ghi chú',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Color(0xFFFBBF24)),
                            ),
                            child: Text(
                              receipt['note'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Helper để format số tiền có dấu phẩy
  String _formatCurrency(dynamic value) {
    if (value == null) return '0';
    try {
      int intValue = value is int ? value : int.parse(value.toString());
      return intValue.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    } catch (e) {
      return value.toString();
    }
  }

  // Giả sử bạn có hàm _buildDetailRow như cũ, nếu không thì có thể định nghĩa:
  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
