import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeView'),
        centerTitle: true,
      ),
      body: Obx(
        () => Column(
          children: [
            // Display status message dynamically
            Text(
              controller.statusMessage.value,
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            // Button to call openCvView
            GestureDetector(
              onTap: () {
                // Call the native method to open OpenCV view
                HomeController.openOpenCVView();
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: const Text(
                  'Open OpenCV View',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Display image if a valid path is received
            if (controller.receivedData.isNotEmpty)
              Column(
                children: [
                  Text(
                    'Image Path: ${controller.receivedData.value}',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.file(
                      File(controller.receivedData.value),
                      fit: BoxFit.cover,
                      width: 300,
                      height: 300,
                    ),
                  ),
                ],
              )
            else
              const Text(
                'No image captured yet.',
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
