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
              // text shiow isApiActive and loading
              Text(
                'API is Active',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              // Show loading indicator or card details

              Obx(() {
                if (controller.isLoading.value) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    decoration: BoxDecoration(
                      // center loading of screenm
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  );
                } else if (controller.card.value.idNumber.isNotEmpty &&
                    !controller.isLoading.value) {
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
              // Loading Indicator
              Obx(() {
                if (controller.isLoading.value) {
                  return Container(
                    color: Colors.black.withOpacity(0.5), // Transparent overlay
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 204, 0, 0)),
                    ),
                  );
                } else {
                  return const SizedBox.shrink(); // Do not render anything
                }
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value) {
          return Container(); // Hide bottom navigation when loading
        } else {
          return _buildBottomNavigationBar(context);
        }
      }),
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
            _buildEditableRow('Card ID:', controller.card.value.idNumber.obs),
            _buildEditableRow('Prefix:', controller.card.value.th.prefix.obs),
            _buildEditableRow('First Name:', controller.card.value.th.name.obs),
            _buildEditableRow(
                'Last Name:', controller.card.value.th.lastName.obs),
            _buildEditableRow(
                'Date of Birth:', controller.card.value.th.dateOfBirth.obs),
            _buildEditableRow(
                'Date of Issue:', controller.card.value.th.dateOfIssue.obs),
            _buildEditableRow(
                'Date of Expiry:', controller.card.value.th.dateOfExpiry.obs),
            _buildEditableRow(
                'Address:', controller.card.value.th.address.full.obs),
            SizedBox(height: screenWidth * 0.04),
            const Text(
              'บัตรประชาชน (EN)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildEditableRow('Card ID:', controller.card.value.idNumber.obs),
            _buildEditableRow('Prefix:', controller.card.value.en.prefix.obs),
            _buildEditableRow('First Name:', controller.card.value.en.name.obs),
            _buildEditableRow(
                'Last Name:', controller.card.value.en.lastName.obs),
            _buildEditableRow(
                'Date of Birth:', controller.card.value.en.dateOfBirth.obs),
            _buildEditableRow(
                'Date of Issue:', controller.card.value.en.dateOfIssue.obs),
            _buildEditableRow(
                'Date of Expiry:', controller.card.value.en.dateOfExpiry.obs),
            SizedBox(height: screenWidth * 0.04),
            const Divider(),
            _buildEditableRow(
                'Laser Code:', controller.card.value.laserCode.obs),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableRow(String label, RxString value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Obx(
              () => TextField(
                controller: TextEditingController(text: value.value)
                  ..selection =
                      TextSelection.collapsed(offset: value.value.length),
                onChanged: (text) => value.value = text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                ),
              ),
            ),
          ),
        ],
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
        StepWidget(step: 1, text: "ถ่ายภาพหน้บัตรประชาชน"),
        StepWidget(step: 2, text: "ถ่ายภาพหน้าบัตรประชาชน"),
        StepWidget(step: 3, text: "ถ่ายภาพหน้าตัวเอง"),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BottomAppBar(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white, // Set background to white
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
            child: Obx(() {
              if (controller.similarity.value != 0) {
                // Congratulatory message with Clear Data button
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: screenWidth * 0.02),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.1,
                            vertical: screenWidth * 0.03), // Dynamic padding
                      ),
                      onPressed: () {
                        controller.clearDataForNewOCR();
                        controller.isApiActive.value = true;
                      },
                      child: Text(
                        'Clear Data for Restart',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              } else if (controller.card.value.idNumber.isEmpty) {
                // Start button
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.15,
                        vertical: screenWidth * 0.03), // Dynamic padding
                  ),
                  onPressed: () {
                    controller.openCameraPage();
                    controller.isApiActive.value = true;
                  },
                  child: Text(
                    'เริ่มต้น', // "Start"
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              } else {
                // Continue and Clear Data buttons
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: screenWidth * 0.03),
                        ),
                        onPressed: controller.openScanFace,
                        child: Text(
                          'ต่อไป', // "Next"
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Flexible(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: screenWidth * 0.03),
                        ),
                        onPressed: controller.clearDataForNewOCR,
                        child: Text(
                          'Clear Data',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            }),
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
