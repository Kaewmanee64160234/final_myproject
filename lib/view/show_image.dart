import 'dart:convert'; // For Base64 decoding
import 'dart:typed_data'; // For Uint8List
import 'package:flutter/material.dart';

class Base64ImageScreen extends StatelessWidget {
  final String base64String;

  Base64ImageScreen({required this.base64String});

  @override
  Widget build(BuildContext context) {
    // Decode the Base64 string into bytes
    Uint8List decodedBytes = base64Decode(base64String);

    return Scaffold(
      appBar: AppBar(title: Text("Base64 Image")),
      body: Center(
        child: Image.memory(
          decodedBytes,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
