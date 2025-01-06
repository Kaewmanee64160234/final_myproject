import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:identity_scan/api/api.dart';

class ImageView extends StatefulWidget {
  final String imagePath; // Accept the image file path as a parameter

  const ImageView({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  Uint8List? imageBytes; // To store the loaded image bytes

  @override
  void initState() {
    super.initState();
    loadImageFromPath();
  }

  // Load image from file path
  Future<void> loadImageFromPath() async {
    try {
      final file = File(widget.imagePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes(); // Read file as bytes
        setState(() {
          imageBytes = bytes; // Store the bytes in state
        });
      } else {
        throw Exception("File does not exist at ${widget.imagePath}");
      }
    } catch (e) {
      print("Error loading image from path: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Captured Image')),
      body: Center(
        child: imageBytes != null
            ? Image.memory(imageBytes!) // Display the image once loaded
            : const CircularProgressIndicator(), // Show loading indicator
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: uploadImage,
        child: const Icon(Icons.upload),
      ),
    );
  }

  void uploadImage() async {
    if (imageBytes == null) {
      print("No image loaded to upload.");
      return;
    }

    Api api = Api('https://events.controldata.co.th/cardocr/');
    String base64Image = base64Encode(imageBytes!); // Convert image to Base64
    Map<String, dynamic> formData = {
      'filedata': base64Image, // Send Base64-encoded image
    };

    try {
      final response = await api.post('upload_front_Base64', formData);
      // print("Upload response: $response");
    } catch (e) {
      print("Error uploading image: $e");
    }
  }
}
