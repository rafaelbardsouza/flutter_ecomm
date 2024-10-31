// lib/database/product_model.dart
class ProductModel {
  final int id;
  final String? title; // Nullable
  final double? price; // Nullable
  final String? imageUrl; // Nullable
  final String? category;
  final String? description;
  final Rating? rating;

  ProductModel({
    required this.id,
    this.title,
    this.price,
    this.imageUrl,
    this.category,
    this.description,
    this.rating,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'] as String?, // Cast to nullable type
      price:
          (json['price'] as num?)?.toDouble(), // Handle nullable numeric fields
      imageUrl: json['image'] as String?,
      category: json['category'] as String?,
      description: json['description'] as String?,
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
