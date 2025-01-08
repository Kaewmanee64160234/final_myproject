import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:identity_scan/api/api.dart';

class LoadingView extends StatefulWidget {
  const LoadingView({super.key});

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  static String imagePath =
      '/data/user/0/com.example.identity_scan/app_Images/image.jpg';
  static late Uint8List imageBytes;
  static late String base64Image;
  static Api api = Api();

  Future<void> loadImageFromPath() async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        setState(() {
          imageBytes = bytes;
        });
      } else {
        throw Exception("File does not exist at ${imagePath}");
      }
    } catch (e) {
      print("Error loading image from path: $e");
    }
  }

  void convertToBase64() {
    String base64Encoded = base64Encode(imageBytes);
    setState(() {
      base64Image = base64Encoded;
    });
  }

  void loadImageAndStartOCR() async {
    await loadImageFromPath();
    convertToBase64();
    await api.sendOcrFront(base64Image);
  }

  @override
  void initState() {
    print("Init State");
    // เรียกไฟล์รูปภาพมาเก็บที่ตัวแปร
    loadImageAndStartOCR();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: CircularProgressIndicator()),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              "โปรดรอ กำลังทำการดึงข้อมูลจากบัตร",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
