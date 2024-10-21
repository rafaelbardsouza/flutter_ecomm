import 'package:flutter/material.dart';
import 'globals.dart' as globals;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Ecommerce',
      theme: ThemeData(
        primaryColor: Colors.black, // Explicitly set the primary color to black
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black).copyWith(
          primary: Colors.black, // Ensure primary color is black
          secondary: Colors.black, // Set secondary color to black if needed
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Ecommerce'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await globals.getRequest('https://fakestoreapi.com/products');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: globals.products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          :           ListView.builder(
            itemCount: globals.products.length,
            itemBuilder: (context, index) {
              final product = globals.products[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: screenWidth * 0.4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.network(
                              product['image'],
                              width: screenWidth * 0.5, 
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              product['title'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.black,
                              ),
                              child: const Text('Show more'),
                            ),
                            const SizedBox(height: 8.0), // Add this SizedBox for spacing
                            Text(
                              '\$${product['price']}',
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0), // Gap between items
                    ],
                  ),
                ),
              );
            },
          )
    );
  }
}