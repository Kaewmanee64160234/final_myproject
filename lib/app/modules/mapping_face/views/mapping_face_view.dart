import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:identity_scan/app/routes/app_pages.dart';

class MappingFaceView extends StatelessWidget {
  const MappingFaceView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Retrieve passed arguments
    final Map<String, dynamic> args = Get.arguments ?? {};
    final Uint8List? portraitImage = args['portraitImage'];
    final Uint8List? cameraImage = args['cameraImage'];
    final double similarity = args['similarity'] ?? 0.0;

    if (portraitImage == null || cameraImage == null) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Hides the back button
          title: const Text('Error'),
          centerTitle: true,
          backgroundColor: Colors.red,
        ),
        body: const Center(
          child: Text(
            'Invalid data provided. Please try again.',
            style: TextStyle(fontSize: 18, color: Colors.redAccent),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => false, // Prevents navigation back
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Hides the back button
          title: const Text(
            'ค่าความคล้ายคลึง',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(45, 56, 146, 1),
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'ค่าความคล้ายคลึง',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildImageCard(
                    image: portraitImage,
                    label: 'บัตรประชาชน', // "ID Card"
                    screenWidth: screenWidth,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'VS',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  _buildImageCard(
                    image: cameraImage,
                    label: 'ภาพจากกล้อง', // "Camera Image"
                    screenWidth: screenWidth,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'ค่าความคล้ายคลึง: ${(similarity * 100).toStringAsFixed(2)} %',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(
                vertical: screenWidth * 0.03,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Get.offNamed(Routes.RESULT_OCR); // Prevents going back
            },
            child: Text(
              'ถัดไป', // "Next"
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard({
    required Uint8List image,
    required String label,
    required double screenWidth,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              image,
              width: screenWidth * 0.3,
              height: screenWidth * 0.3,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
