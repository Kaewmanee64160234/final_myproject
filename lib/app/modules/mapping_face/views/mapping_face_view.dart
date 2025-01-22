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
          child: Text('Invalid data provided. Please try again.'),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => false, // Prevents navigation back
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Hides the back button
          title: const Text('ค่าความคล้ายคลึง'),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(45, 56, 146, 1),
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'ค่าความคล้ายคลึง',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.15,
                    backgroundImage: MemoryImage(portraitImage),
                  ),
                  const Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  CircleAvatar(
                    radius: screenWidth * 0.15,
                    backgroundImage: MemoryImage(cameraImage),
                  ),
                ],
              ),
              Text(
                'ค่าความคล้ายคลึง: ${(similarity * 100).toStringAsFixed(2)} %',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
              GestureDetector(
                onTap: () {
                  Get.offNamed(Routes.RESULT_OCR); // Prevents going back
                },
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'ถัดไป',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
