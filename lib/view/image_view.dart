import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:identity_scan/api/api.dart';
import 'package:identity_scan/model/front_data.dart';

class ImageView extends StatefulWidget {
  final String imagePath; // Accept the image file path as a parameter

  const ImageView({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  Uint8List? imageBytes; // To store the loaded image bytes
  String base64String = ''; // To store the Base64 string

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
        final bytes = await file.readAsBytes(); 
        setState(() {
          imageBytes = bytes; 
        });
      } else {
        throw Exception("File does not exist at ${widget.imagePath}");
      }
    } catch (e) {
      print("Error loading image from path: $e");
    }
  }

  void convertToBase64() {
    if (imageBytes != null) {
      String base64Encoded =
          base64Encode(imageBytes!); 
      setState(() {
        base64String = base64Encoded;
      });
    } else {
      print("Image not loaded yet.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Captured Image'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share), // Icon for the action button
            onPressed: () {
              print("Share button pressed");
              uploadImageFront();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the image once loaded
            imageBytes != null
                ? Image.memory(imageBytes!)
                : const CircularProgressIndicator(),
            const SizedBox(height: 20),
            // Show the Base64 string if available
            if (base64String.isNotEmpty)
              Column(
                children: [
                  Text(
                    "Base64 Encoded Image:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    base64String,
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ],
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: convertToBase64, 
        child: const Icon(Icons.file_copy), 
      ),
    );
  }

  // Upload the image (if necessary)
  void uploadImageFront() async {
    if (imageBytes == null) {
      print("No image loaded to upload.");
      return;
    }

    Api api = Api('https://events.controldata.co.th/cardocr/');
    Map<String, dynamic> formData = {
      'filedata': base64String, // Send Base64-encoded image
    };

    try {
      final response = await api.post('api/v1/upload_front_base64', formData);
      if(response!=null){
        print(response.body);
      }
      // print(response);
      // print("Upload response: $response");
      // FrontData frontData = FrontData.fromJson(response as Map<String, dynamic>);
      // print(frontData.fullName);
    } catch (e) {
      print("Error uploading image: $e");
    }
  }
}
