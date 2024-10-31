import 'package:flutter_ecomm/database/app_database.dart';
import 'package:flutter_ecomm/database/product_model.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductService {
  final AppDatabase database;

  ProductService(this.database);

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

  Future<List<ProductModel>> fetchProductsFromDb() async {
    try {
      print("Starting to fetch products from the local database...");

      final dbProducts = await database.select(database.products).get();

      if (dbProducts.isEmpty) {
        print("No products found in the local database.");
      } else {
        print("Fetched ${dbProducts.length} products from the database:");
        for (var product in dbProducts) {
          print(
              ' - Product ID: ${product.id}, Title: ${product.title}, Price: ${product.price}, Image URL: ${product.imageUrl}');
        }
      }

      return dbProducts.map((product) {
        return ProductModel(
          id: product.id,
          title: product.title,
          price: product.price,
          imageUrl: product.imageUrl,
        );
      }).toList();
    } catch (e) {
      print("Error fetching products from the database: $e");
      return [];
    }
  }

  Future<void> insertProductsIntoDb(List<ProductModel> products) async {
    await database.batch((batch) {
      batch.insertAll(
        database.products,
        products.map((product) {
          final truncatedTitle =
              (product.title != null && product.title!.length > 50)
                  ? product.title!.substring(0, 50)
                  : product.title;

          print(
              'Inserting product - ID: ${product.id}, Title: ${truncatedTitle}, Price: ${product.price ?? 0.0}, Image URL: ${product.imageUrl ?? ""}');

          return ProductsCompanion(
            id: Value(product.id),
            title: Value(truncatedTitle ?? "Unknown title"),
            price: Value(product.price ?? 0.0),
            imageUrl: Value(product.imageUrl ?? ""),
          );
        }).toList(),
      );
    });
  }

  Future<void> logDatabaseContents() async {
    final products = await fetchProductsFromDb();
    print("Logging all products in the database:");
    for (var product in products) {
      print(
          ' - Database content - ID: ${product.id}, Title: ${product.title}, Price: ${product.price}, Image URL: ${product.imageUrl}');
    }
  }
}
