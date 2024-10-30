import 'package:flutter_ecomm/database/app_database.dart';
import 'package:flutter_ecomm/database/product_model.dart'; // Import ProductModel
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;

class ProductService {
  final AppDatabase database;

  ProductService(this.database);

  // Method to fetch products from local database
  Future<List<ProductModel>> fetchProductsFromDb() async {
    final dbProducts = await database.select(database.products).get();
    return dbProducts
        .map((product) => ProductModel(
              id: product.id,
              title: product.title,
              price: product.price,
              imageUrl: product.imageUrl,
            ))
        .toList();
  }

  // Method to fetch products from the API
  Future<List<ProductModel>> fetchProductsFromApi() async {
    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/products'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load products from API");
    }
  }

  // Method to insert fetched products into local database
  Future<void> insertProductsIntoDb(List<ProductModel> products) async {
    await database.batch((batch) {
      batch.insertAll(
        database.products,
        products.map((product) {
          return ProductsCompanion(
            id: Value(product.id),
            title: Value(product.title),
            price: Value(product.price),
            imageUrl: Value(product.imageUrl),
          );
        }).toList(),
      );
    });
  }
}
