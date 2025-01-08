import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:identity_scan/api/api.dart';
import 'package:identity_scan/model/front/id_card.dart';
import 'package:identity_scan/view/result/front_result_view.dart';

import '../result/error_view.dart';

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
        showSuccessSnackbar(title: "Success",message: "Load Image Sucess");
      } else {
        throw Exception("File does not exist at ${imagePath}");
      }
    } catch (e) {
      showErrorSnackbar(title: "Error", message: e.toString());
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
    ID_CARD? result = await api.sendOcrFront(base64Image);
    if (result != null) {
      Get.to(FrontResultView(idCard: result));
    } else {
      Get.to(ErrorView());
      print("No Result");
    }
  }

  void showErrorSnackbar({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      titleText: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      messageText: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  
  void showSuccessSnackbar({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      titleText: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      messageText: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
    );
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
