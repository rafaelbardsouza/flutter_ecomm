// lib/database/product_model.dart
class ProductModel {
  final int id;
  final String title;
  final double price;
  final String imageUrl;
  final String? category;
  final String? description;
  final Rating? rating;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.category,
    this.description,
    this.rating,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'],
      category: json['category'],
      description: json['description'],
      rating: json['rating'] != null ? Rating.fromJson(json['rating']) : null,
    );
  }
}

// Assuming `Rating` is a nested object
class Rating {
  final double rate;
  final int count;

  Rating({
    required this.rate,
    required this.count,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rate: (json['rate'] as num).toDouble(),
      count: json['count'],
    );
  }
}
