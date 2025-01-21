import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:identity_scan/app/modules/home/views/home_view.dart';

import '../controllers/flow_detact_controller.dart';

class FlowDetactView extends GetView<FlowDetactController> {
  const FlowDetactView({super.key});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
        padding: EdgeInsets.all(screenWidth * 0.04), // Dynamic padding
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
                        radius: screenWidth * 0.15, // Responsive radius
                        backgroundImage: MemoryImage(
                          controller.card.value.getDecodedPortrait(),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      Text(
                        'LaserCode: ${controller.laserCodeOriginal.value}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04, // Responsive font size
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      _buildCardDetails(context),
                    ],
                  );
                } else {
                  return _buildRegistrationSteps(context);
                }
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(() => Container(
            child: _buildBottomNavigationBar(context),
            color: controller.card.value.idNumber.isNotEmpty
                ? Colors.white
                : Colors.blueGrey[100],
          )),
    );
  }

  Widget _buildCardDetails(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(screenWidth * 0.04), // Dynamic margins
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04), // Dynamic padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'บัตรประชาชน (TH)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('Card ID:', controller.card.value.idNumber),
            _buildInfoRow('Prefix:', controller.card.value.th.prefix),
            _buildInfoRow('Full Name (TH):', controller.card.value.th.fullName),
            _buildInfoRow('First Name:', controller.card.value.th.name),
            _buildInfoRow('Last Name:', controller.card.value.th.lastName),
            _buildInfoRow(
                'Date of Birth:', controller.card.value.th.dateOfBirth),
            _buildInfoRow(
                'Date of Issue:', controller.card.value.th.dateOfIssue),
            _buildInfoRow(
                'Date of Expiry:', controller.card.value.th.dateOfExpiry),
            _buildInfoRow('Address:', controller.card.value.th.address.full),
            SizedBox(height: screenWidth * 0.04),
            const Text(
              'บัตรประชาชน (EN)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('Card ID:', controller.card.value.idNumber),
            _buildInfoRow('Prefix:', controller.card.value.en.prefix),
            _buildInfoRow('Full Name (EN):', controller.card.value.en.fullName),
            _buildInfoRow('First Name:', controller.card.value.en.name),
            _buildInfoRow('Last Name:', controller.card.value.en.lastName),
            _buildInfoRow(
                'Date of Birth:', controller.card.value.en.dateOfBirth),
            _buildInfoRow(
                'Date of Issue:', controller.card.value.en.dateOfIssue),
            _buildInfoRow(
                'Date of Expiry:', controller.card.value.en.dateOfExpiry),
            _buildInfoRow('Address:', controller.card.value.en.address.full),
            // show similarity
            SizedBox(height: screenWidth * 0.04),
            const Text(
              'Similarity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow(
              'Similarity:',
              controller.similarity.value.toStringAsFixed(2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationSteps(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        SizedBox(height: screenWidth * 0.05),
        const Image(
          image: AssetImage('assets/images/data-protection.png'),
          width: 200,
          height: 200,
        ),
        SizedBox(height: screenWidth * 0.05),
        Text(
          "ขั้นตอนการลงทะเบียนด้วยตนเอง",
          style: TextStyle(fontSize: screenWidth * 0.05),
        ),
        SizedBox(height: screenWidth * 0.05),
        GridView.count(
          crossAxisCount: screenWidth > 600 ? 4 : 2, // Responsive columns
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            StepWidget(step: 1, text: "ถ่ายภาพหน้บัตรประชาชน"),
            StepWidget(step: 2, text: "ถ่ายภาพหน้าบัตรประชาชน"),
            StepWidget(step: 3, text: "ถ่ายภาพหน้าตัวเอง"),
            StepWidget(step: 4, text: "สร้างรหัส 8 หลัก"),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BottomAppBar(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
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
                  child: Text(
                    'เริ่มต้น',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                      child: Text(
                        'ต่อไป',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
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
                      child: Text(
                        'Clear Data',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
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
