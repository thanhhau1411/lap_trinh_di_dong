class Thumbnail {
  final int id;           // Mã ảnh thumbnail
  final int productId;    // Mã sản phẩm liên kết
  final String imageUrl;     // Đường dẫn ảnh

  Thumbnail({
    required this.id,
    required this.productId,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'imageUrl': imageUrl,
    };
  }

  factory Thumbnail.fromMap(Map<String, dynamic> map) {
    return Thumbnail(
      id: map['id'],
      productId: map['productId'],
      imageUrl: map['imageUrl'],
    );
  }
}
