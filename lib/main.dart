import 'package:flutter/material.dart';
import 'package:flutter_ecomm/screens/product.dart';
import 'package:local_auth/local_auth.dart';
import 'widgets/pin_input_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_ecomm/screens/product.dart';
import 'services/product_service.dart';
import 'database/app_database.dart';
import 'database/product_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  final AppDatabase database = AppDatabase.instance;
  final ProductService productService;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  _MyHomePageState() : productService = ProductService(AppDatabase.instance);

  bool _isAuthenticated = false;
  bool _isLoading = true;
  List<ProductModel> products = [];

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (canCheckBiometrics && isDeviceSupported) {
        final isAuthenticated = await auth.authenticate(
          localizedReason: 'Please authenticate to access your products',
          options: const AuthenticationOptions(
            biometricOnly: true,
          ),
        );

        if (isAuthenticated) {
          setState(() {
            _isAuthenticated = true;
            _isLoading = false;
          });
          await _loadProducts();
          return;
        }
      }

      _showPinAuthentication();
    } catch (e) {
      print("Authentication error: $e");
      _showPinAuthentication();
    }
  }

  void _showPinAuthentication() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter PIN'),
          content: PinInputScreen(
            onPinEntered: _validatePin,
          ),
        );
      },
    );
  }

  Future<void> _validatePin(String enteredPin) async {
    final savedPin = await _secureStorage.read(key: 'userPin');

    if (savedPin == null) {
      await _secureStorage.write(key: 'userPin', value: enteredPin);
      print("PIN set successfully");
      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });
      Navigator.of(context).pop();
      await _loadProducts();
    } else if (enteredPin == savedPin) {
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

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      products = await productService.fetchProductsFromDb();

      if (products.isNotEmpty) {
        print("Loaded products from DB.");
      } else {
        var connectivityResult = await (Connectivity().checkConnectivity());

        if (connectivityResult == ConnectivityResult.none) {
          print("No internet connection and no local products available.");
        } else {
          print("No products found in DB. Fetching from API...");
          products = await productService.fetchProductsFromApi();
          await productService.insertProductsIntoDb(products);
          print("Fetched products from API and inserted into DB.");
        }
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
                                        product.imageUrl ??
                                            'https://via.placeholder.com/150',
                                        width: screenWidth * 0.5,
                                      ),
                                      Text(
                                        product.title ?? "No title available",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductScreen(
                                                      product: product),
                                            ),
                                          );
                                        },
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
