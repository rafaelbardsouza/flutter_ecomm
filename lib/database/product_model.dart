class ProductModel {
  final int id;
  final String? title;
  final double? price;
  final String? imageUrl;
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
      title: json['title'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      imageUrl: json['image'] as String?,
      category: json['category'] as String?,
      description: json['description'] as String?,
      rating: json['rating'] != null ? Rating.fromJson(json['rating']) : null,
    );
  }
}

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
