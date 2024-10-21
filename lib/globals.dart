// File: globals.dart
library globals;

import 'package:http/http.dart' as http;
import 'dart:convert';

// Define a products list
List<dynamic> products = [];

Future<void> getRequest(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      products = data; // Populate the products list
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  } catch (e) {
    print('Error: $e');
  }
}