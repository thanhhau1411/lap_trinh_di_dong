class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  int quantity;
  final String imageUrl;
  int brandId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.brandId
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'brandId': brandId
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      quantity: map['quantity'],
      imageUrl: map['imageUrl'],
      brandId: map['brandId']
    );
  }
}
