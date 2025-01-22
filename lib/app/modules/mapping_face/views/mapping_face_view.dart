import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:identity_scan/app/routes/app_pages.dart';

import '../controllers/mapping_face_controller.dart';

class MappingFaceView extends GetView<MappingFaceController> {
  const MappingFaceView({super.key});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ค่าความคล้ายคลึง'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(45, 56, 146, 1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // ขั้นตอนการลงทะเบียน
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'ค่าความคล้ายคลึง',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            // show image compare 2 avatar from card.profile and imageFromCameraBase64
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.15, // Responsive radius
                  backgroundImage: MemoryImage(
                    controller.flowDetectController.card.value
                        .getDecodedPortrait(),
                  ),
                ),
                // vs
                Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
                CircleAvatar(
                  radius: screenWidth * 0.15, // Responsive radius
                  backgroundImage: MemoryImage(
                      controller.flowDetectController.getDecodedPortrait()),
                ),
              ],
            ),
            // show similarity value
            Text(
              'ค่าความคล้ายคลึง: ${(controller.flowDetectController.similarity.value * 100).toStringAsFixed(2)} %',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
            // next button
            // button to go to next page
            GestureDetector(
              onTap: () {
                Get.toNamed(Routes.RESULT_OCR);
              },
              child: Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
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
    );
  }
}
