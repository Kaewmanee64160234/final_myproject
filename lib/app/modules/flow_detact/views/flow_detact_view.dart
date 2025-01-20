import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:identity_scan/app/modules/home/views/home_view.dart';

import '../controllers/flow_detact_controller.dart';

class FlowDetactView extends GetView<FlowDetactController> {
  const FlowDetactView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ขั้นตอนการลงทะเบียน',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(3, 6, 80, 1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(() {
                if (controller.isLoading.value) {
                  return const CircularProgressIndicator();
                } else if (controller.card.value.idNumber.isNotEmpty) {
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: MemoryImage(
                          controller.card.value.getDecodedPortrait(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'LaserCode: ${controller.laserCodeOriginal.value}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCardDetails(),
                    ],
                  );
                } else {
                  return _buildRegistrationSteps();
                }
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(() => _buildBottomNavigationBar()),
    );
  }

  Widget _buildCardDetails() {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'บัตรประชาชน (TH)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          _buildInfoRow('Card ID:', controller.card.value.idNumber),
          _buildInfoRow('Full Name (TH):', controller.card.value.th.fullName),
          // Add more fields as needed...
        ],
      ),
    );
  }

  Widget _buildRegistrationSteps() {
    return Column(
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
            children: const [
              StepWidget(step: 1, text: "ถ่ายภาพหน้บัตรประชาชน"),
              StepWidget(step: 2, text: "ถ่ายภาพหน้าบัตรประชาชน"),
              StepWidget(step: 3, text: "ถ่ายภาพหน้าตัวเอง"),
              StepWidget(step: 4, text: "สร้างรหัส 8 หลัก"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      child: Container(
        color: Colors.white,
        child: Center(
          child: controller.card.value.idNumber.isEmpty
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.openCameraPage,
                  child: const Text(
                    'เริ่มต้น',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: controller.openScanFace,
                      child: const Text(
                        'ต่อไป',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: controller.clearDataForNewOCR,
                      child: const Text(
                        'Clear Data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value != null && value.isNotEmpty ? value : 'N/A',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
