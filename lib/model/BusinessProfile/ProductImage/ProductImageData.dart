class ProductImageData {
  final String productImage;

  ProductImageData({required this.productImage});

  factory ProductImageData.fromJson(Map<String, dynamic> json) {
    final imageData = json['1'] ?? json;

    return ProductImageData(
      productImage: imageData['product_image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_image': productImage,
    };
  }
}
