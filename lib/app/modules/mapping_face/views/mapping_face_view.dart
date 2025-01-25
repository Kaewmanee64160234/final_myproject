import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:identity_scan/app/data/models/card_type.dart';
import 'package:identity_scan/app/data/models/services/similarity.dart';
import 'package:identity_scan/app/modules/flow_detact/controllers/flow_detact_controller.dart';
import 'package:identity_scan/app/routes/app_pages.dart';

class MappingFaceView extends GetView<FlowDetactController> {
  final ID_CARD card;
  final Similarity similarity;

  // Constructor ที่รับค่าพารามิเตอร์ card และ similarity เป็น required parameters
  MappingFaceView({
    super.key,
    required this.card,
    required this.similarity,
  });

  @override
  Widget build(BuildContext context) {
    FlowDetactController flowDetactController = Get.put(FlowDetactController());
    final screenWidth = MediaQuery.of(context).size.width;

    // ignore: deprecated_member_use
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
          body: Obx((() {
            if (flowDetactController.isLoading.value) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: similarity.similarity >= 0.98
                        ? [
                            Colors.green.shade400,
                            Colors.blue.shade400
                          ] // Success gradient
                        : [
                            Colors.orange.shade400,
                            Colors.red.shade400
                          ], // Failure gradient
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ข้อความ "กำลังเปรียบเทียบ"

                      Container(
                        width: 100, // ขนาดของวงกลม
                        height: 100,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white), // สีของ progress
                            backgroundColor:
                                Colors.transparent, // ไม่มีสีพื้นหลัง
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'กำลังเปรียบเทียบ',
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // ข้อความสีขาว
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: similarity.similarity >= 0.98
                        ? [
                            Colors.green.shade400,
                            Colors.blue.shade400
                          ] // Success gradient
                        : [
                            Colors.orange.shade400,
                            Colors.red.shade400
                          ], // Failure gradient
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'ค่าความคล้ายคลึง',
                            style: TextStyle(
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCircularAvatar(
                              image: base64Decode(card.portrait),
                              label: 'บัตรประชาชน', // "ID Card"
                              screenWidth: screenWidth,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'VS',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            _buildCircularAvatar(
                              image: similarity.cameraImage,
                              label: 'ภาพจากกล้อง', // "Camera Image"
                              screenWidth: screenWidth,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'ค่าความคล้ายคลึง: ${(similarity.similarity * 100).toStringAsFixed(2)} %',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: similarity.similarity >= 0.98
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenWidth * 0.04,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    Get.offNamed(Routes.RESULT_OCR, arguments: {
                                      'card': card,
                                    });

                                    // Get.to(ResultOcrView());
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'ดูข้อมูลทั้งหมด', // "Next"
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.05,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: EdgeInsets.symmetric(
                                          vertical: screenWidth * 0.04,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () {
                                        flowDetactController.openScanFace();
                                        // Get.offAllNamed(Routes.HOME); // Go back to Home
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'ลองใหม่อีกครั้ง', // "You didn't pass the criteria, please try again."
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.045,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: EdgeInsets.symmetric(
                                          vertical: screenWidth * 0.04,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () {
                                        Get.offAllNamed(
                                            Routes.HOME); // Go back to Home
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'กลับหน้าหลัก', // "You didn't pass the criteria, please try again."
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.045,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }))),
    );
  }

  Widget _buildCircularAvatar({
    required Uint8List image,
    required String label,
    required double screenWidth,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: screenWidth * 0.15,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: screenWidth * 0.14,
            backgroundImage: MemoryImage(image),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
