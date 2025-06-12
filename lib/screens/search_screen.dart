import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchstore/controllers/brand_controller.dart';
import 'package:watchstore/controllers/product_controller.dart';
import 'package:watchstore/models/data/brand.dart';
import 'package:watchstore/models/data/product.dart';
import 'package:watchstore/models/data/product_attribute_value.dart';
import 'package:watchstore/models/data/thumbnail.dart';
import 'package:watchstore/models/data/watch_attribute.dart';
import 'package:watchstore/screens/product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _brandController = BrandController();
  late ProductController _productController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Brand> brands = [];
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  List<String> searchHistory = [];
  
  String searchQuery = '';
  int? selectedBrandId;
  bool isLoading = false;
  bool showFilters = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productController = Provider.of<ProductController>(context);
    loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadInitialData() async {
    setState(() => isLoading = true);
    
    try {
      final [loadedBrands, loadedProducts] = await Future.wait([
        _brandController.loadAll(),
        _productController.getAll(),
      ]);
      
      setState(() {
        brands = loadedBrands as List<Brand>;
        allProducts = loadedProducts as List<Product>;
        filteredProducts = allProducts;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
        );
      }
    }
  }

  void _performSearch(String query) {
    setState(() {
      searchQuery = query;
      _filterProducts();
    });
    
    if (query.isNotEmpty && !searchHistory.contains(query)) {
      setState(() {
        searchHistory.insert(0, query);
        if (searchHistory.length > 10) {
          searchHistory = searchHistory.take(10).toList();
        }
      });
    }
    
    _animationController.reset();
    _animationController.forward();
  }

  void _filterProducts() {
    List<Product> filtered = allProducts;

    // Lọc theo từ khóa tìm kiếm
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               product.description.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Lọc theo thương hiệu
    if (selectedBrandId != null) {
      filtered = filtered.where((product) => product.brandId == selectedBrandId).toList();
    }

    setState(() {
      filteredProducts = filtered;
    });
  }

  void _clearFilters() {
    setState(() {
      selectedBrandId = null;
      _filterProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: _performSearch,
            onSubmitted: _performSearch,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm đồng hồ...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              showFilters ? Icons.filter_list : Icons.tune,
              color: showFilters ? Colors.red : Colors.black,
            ),
            onPressed: () {
              setState(() {
                showFilters = !showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Bộ lọc
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: showFilters ? null : 0,
            child: showFilters ? _buildFilters() : const SizedBox.shrink(),
          ),
          
          // Nội dung chính
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : searchQuery.isEmpty
                    ? _buildSearchSuggestions()
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bộ lọc',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Xóa tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Lọc theo thương hiệu
          const Text('Thương hiệu:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: brands.length,
              itemBuilder: (context, index) {
                final brand = brands[index];
                final isSelected = selectedBrandId == brand.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedBrandId = isSelected ? null : brand.id;
                      _filterProducts();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      brand.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (searchHistory.isNotEmpty) ...[
            const Text(
              'Tìm kiếm gần đây',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...searchHistory.map((query) => ListTile(
              leading: const Icon(Icons.history, color: Colors.grey),
              title: Text(query),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    searchHistory.remove(query);
                  });
                },
              ),
              onTap: () {
                _searchController.text = query;
                _performSearch(query);
              },
            )),
            const SizedBox(height: 24),
          ],
          
          const Text(
            'Gợi ý tìm kiếm',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Rolex',
              'Omega',
              'Casio',
              'Apple Watch',
              'Samsung Galaxy Watch',
              'Đồng hồ thể thao',
              'Đồng hồ cơ',
              'Đồng hồ nam',
              'Đồng hồ nữ',
            ].map((suggestion) => GestureDetector(
              onTap: () {
                _searchController.text = suggestion;
                _performSearch(suggestion);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  suggestion,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy sản phẩm nào',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử tìm kiếm với từ khóa khác',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Tìm thấy ${filteredProducts.length} sản phẩm',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      0.1 * (index % 4),
                      1.0,
                      curve: Curves.easeOutCubic,
                    ),
                  )),
                  child: SearchProductCard(product: product),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class SearchProductCard extends StatelessWidget {
  final Product product;
  late ProductController _productController;

  SearchProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    _productController = context.watch<ProductController>();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image với hiệu ứng hero
          Hero(
            tag: 'product_${product.id}',
            child: Container(
              height: 120,
              width: double.infinity,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              product.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const Spacer(),
          
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () => _navigateToProductDetail(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Xem',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToProductDetail(BuildContext context) async {
    final productId = product.id;
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ID sản phẩm không hợp lệ")),
      );
      return;
    }

    try {
      final [thumbnails, watchAttribute] = await Future.wait([
        _productController.getThumbnail(productId),
        _productController.getWatchAttribute(productId),
      ]);
      thumbnails as List<Thumbnail>;
      watchAttribute as List<WatchAttribute>;
      final attributes = watchAttribute ?? [];
      if (attributes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không có thông tin thuộc tính")),
        );
      }

      final futures = attributes.map((attr) {
        final attrId = attr.attributeId;
        if (attrId == null) return Future.value(null);
        return _productController.getAttributeValue(productId, attrId);
      }).toList();

      final attributeValues = await Future.wait(futures);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: product,
              thumbnails: thumbnails,
              attributeValues: attributeValues
                  .whereType<ProductAttributeValue>()
                  .toList(),
              attributes: attributes,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi tải thông tin: $e")),
        );
      }
    }
  }
}