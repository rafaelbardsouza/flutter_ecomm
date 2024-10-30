import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'widgets/pin_input_screen.dart'; // Import PinInputScreen
import 'services/product_service.dart';
import 'database/app_database.dart';
import 'database/product_model.dart';

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
        primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black).copyWith(
          primary: Colors.black,
          secondary: Colors.black,
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
  final LocalAuthentication auth = LocalAuthentication();
  final AppDatabase database = AppDatabase();
  final ProductService productService;

  _MyHomePageState() : productService = ProductService(AppDatabase());

  bool _isAuthenticated = false;
  bool _isLoading = true;
  List<ProductModel> products = []; // Use ProductModel for the list

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  void _showPinAuthentication() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter PIN'),
          content: PinInputScreen(
            onPinEntered: (String pin) {
              _validatePin(pin);
            },
          ),
        );
      },
    );
  }

  void _validatePin(String enteredPin) async {
    const correctPin = "1234";
    if (enteredPin == correctPin) {
      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });
      Navigator.of(context).pop();
      await _loadProducts();
    } else {
      print("Incorrect PIN");
    }
  }

  Future<void> _authenticate() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
        _showPinAuthentication(); // Call PIN authentication if biometrics are unavailable
        return;
      }

      final isAuthenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to access your products',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );

      setState(() {
        _isAuthenticated = isAuthenticated;
        _isLoading = !isAuthenticated;
      });

      if (isAuthenticated) {
        await _loadProducts(); // Updated to _loadProducts
      } else {
        _showPinAuthentication(); // Show PIN authentication if biometrics fail
      }
    } catch (e) {
      print("Authentication error: $e");
      setState(() {
        _isLoading = false;
      });
      _showPinAuthentication(); // Fall back to PIN authentication on error
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Check for products in the local database
      products = await productService.fetchProductsFromDb();

      if (products.isEmpty) {
        // Step 2: If no products in DB, fetch from the API
        print("No products found in DB. Fetching from API...");
        products = await productService.fetchProductsFromApi();

        // Step 3: Insert fetched products into the local database
        await productService.insertProductsIntoDb(products);
        print("Fetched products from API and inserted into DB.");
      } else {
        print("Loaded products from DB.");
      }
    } catch (e) {
      print("Error loading products: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isAuthenticated
              ? Center(
                  child: ElevatedButton(
                    onPressed: _authenticate,
                    child: const Text("Authenticate to Continue"),
                  ),
                )
              : products.isEmpty
                  ? const Center(child: Text("No products available"))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Column(
                              children: [
                                Container(
                                  width: screenWidth * 0.4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.network(
                                        product.imageUrl,
                                        width: screenWidth * 0.5,
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        product.title,
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
                                      const SizedBox(height: 8.0),
                                      Text(
                                        '\$${product.price}',
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
