import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageView extends StatefulWidget {
  final Uint8List imageBytes; // Accept the image byte array as a parameter

  const ImageView({Key? key, required this.imageBytes}) : super(key: key);

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Captured Image')),
      body: Center(
        child: Image.memory(widget.imageBytes),
      ),
    );
  }
}
