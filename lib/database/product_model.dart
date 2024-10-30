// lib/database/product_model.dart
class ProductModel {
  final int id;
  final String title;
  final double price;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
  });

  // Factory constructor to create a ProductModel  instance from a JSON object
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
    );
  }
}
