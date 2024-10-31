import 'package:flutter/material.dart';

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
