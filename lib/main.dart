import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
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
  bool _isAuthenticated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authenticate();
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
        await _fetchData();
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
    const correctPin = "1234"; // Example PIN; retrieve or hash as needed
    if (enteredPin == correctPin) {
      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });
      Navigator.of(context).pop(); // Close the PIN input dialog
      await _fetchData();
    } else {
      print("Incorrect PIN");
      // Show error message or feedback
    }
  }

  Future<void> _fetchData() async {
    try {
      await globals.getRequest('https://fakestoreapi.com/products');
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print(e);
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
              : globals.products.isEmpty
                  ? const Center(child: Text("No products available"))
                  : ListView.builder(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                      const SizedBox(height: 8.0),
                                      Text(
                                        '\$${product['price']}',
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

// Widget for PIN input
class PinInputScreen extends StatefulWidget {
  final Function(String) onPinEntered;

  const PinInputScreen({required this.onPinEntered, Key? key})
      : super(key: key);

  @override
  _PinInputScreenState createState() => _PinInputScreenState();
}

class _PinInputScreenState extends State<PinInputScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter PIN',
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onPinEntered(_pinController.text);
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
