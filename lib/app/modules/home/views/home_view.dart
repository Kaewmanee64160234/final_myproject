import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:identity_scan/app/routes/app_pages.dart';
import 'dart:io';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ขั้นตอนการลงทะเบียน',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(45, 56, 146, 1),
      ),
      body: Obx(
        () => Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Image(
                    image: AssetImage('assets/images/data-protection.png'),
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "ขั้นตอนการลงทะเบียนด้วยตนเอง",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        StepWidget(
                          step: 1,
                          text: "ถ่ายภาพหน้บัตรประชาชน",
                        ),
                        StepWidget(
                          step: 2,
                          text: "ถ่ายภาพหน้าบัตรประชาชน",
                        ),
                        StepWidget(
                          step: 3,
                          text: "ถ่ายภาพหน้าตัวเอง",
                        ),
                        StepWidget(
                          step: 4,
                          text: "สร้างรหัส 8 หลัก",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Button at the bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  // Call the native method to open OpenCV view
                  Get.offNamed(Routes.FLOW_DETACT);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(45, 56, 146, 1),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: const Text(
                    'เริ่มต้น',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StepWidget extends StatelessWidget {
  final int step;
  final String text;

  const StepWidget({
    Key? key,
    required this.step,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circle for the step number
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color.fromRGBO(45, 56, 146, 1),
            child: Text(
              '$step',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12), // Spacing between circle and text
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
