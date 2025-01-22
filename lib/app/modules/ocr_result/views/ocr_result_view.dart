import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:identity_scan/app/modules/ocr_result/controllers/ocr_result_controller.dart';

class OcrResultView extends GetView<OcrResultController> {
  const OcrResultView({super.key});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('OcrResultView'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ตรวจสอบความถูกต้องของข้อมูล
            Text(
              'โปรดตรวจสอบความถูกต้องของข้อมูล',
              style: GoogleFonts.kanit(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            CircleAvatar(
              radius: screenWidth * 0.15, // Responsive radius
              backgroundImage: MemoryImage(
                controller.flowDetectController.card.value.getDecodedPortrait(),
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            _buildCardDetails(controller),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, controller),
    );
  }
}

Widget _buildBottomNavigationBar(
    BuildContext context, OcrResultController controller) {
  final screenWidth = MediaQuery.of(context).size.width;

  return BottomAppBar(
    color: Colors.white, // Set the background to white
    elevation: 0, // Remove shadow if needed
    child: SafeArea(
      child: SingleChildScrollView(
        child: Container(
          color: Colors.white, // Ensure the background remains white
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
          child: Obx(() {
            if (controller.flowDetectController.similarity.value != 0) {
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
                        vertical: screenWidth * 0.03, // Dynamic padding
                      ),
                    ),
                    onPressed: () {
                      controller.flowDetectController.clearDataForNewOCR();
                      controller.flowDetectController.isApiActive.value = true;
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
            } else if (controller.flowDetectController.idNumber.isEmpty) {
              // Start button
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.15,
                    vertical: screenWidth * 0.03, // Dynamic padding
                  ),
                ),
                onPressed: () {
                  controller.flowDetectController.openCameraPage();
                  controller.flowDetectController.isApiActive.value = true;
                },
                child: Text(
                  'เริ่มต้น', // "Start"
                  style: GoogleFonts.kanit(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            } else {
              // Continue and Clear Data buttons
              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.15,
                          vertical: screenWidth * 0.03, // Dynamic padding
                        ),
                      ),
                      onPressed: () {
                        controller.flowDetectController.validateFields();
                        if (controller.flowDetectController.isValid.value) {
                          controller.flowDetectController.openScanFace();
                        }
                      },
                      child: Text(
                        'ไปต่อ', // "Next"
                        style: GoogleFonts.kanit(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                  ],
                ),
              );
            }
          }),
        ),
      ),
    ),
  );
}

Widget _buildCardDetails(OcrResultController controller) {
  return Column(
    children: [
      // แสดงรายละเอียดของบัตรประชาชน
      _buildEditableRow(
        'Card ID',
        controller.flowDetectController.idNumber,
        error: controller.flowDetectController.idNumberError,
        isDisabled: true,
      ),
      // prefix
      _buildEditableRow(
        'Prefix',
        controller.flowDetectController.prefix,
        error: controller.flowDetectController.prefixError,
        isDisabled: true,
      ),
      // first name
      _buildEditableRow(
        'First Name',
        controller.flowDetectController.firstName,
        error: controller.flowDetectController.firstNameError,
        isDisabled: true,
      ),
      // last name
      _buildEditableRow(
        'Last Name',
        controller.flowDetectController.lastName,
        error: controller.flowDetectController.lastNameError,
        isDisabled: true,
      ),
      // date of birth
      _buildEditableRow(
        'Date of Birth',
        controller.flowDetectController.dateOfBirth,
        error: controller.flowDetectController.dateOfBirthError,
        isDisabled: true,
      ),
      // date of issue
      _buildEditableRow(
        'Date of Issue',
        controller.flowDetectController.dateOfIssue,
        error: controller.flowDetectController.dateOfIssueError,
        isDisabled: true,
      ),
      // date of expiry
      _buildEditableRow(
        'Date of Expiry',
        controller.flowDetectController.dateOfExpiry,
        error: controller.flowDetectController.dateOfExpiryError,
        isDisabled: true,
      ),
      // religion
      _buildEditableRow(
        'Religion',
        controller.flowDetectController.religion,
        error: controller.flowDetectController.religionError,
        isDisabled: true,
      ),
      // address
      _buildEditableRow(
        'Address',
        controller.flowDetectController.address,
        error: controller.flowDetectController.addressError,
        isDisabled: true,
      ),
      // eng detail card
      // prefix
      _buildEditableRow(
        'Prefix',
        controller.flowDetectController.prefixEn,
        error: controller.flowDetectController.prefixEnError,
        isDisabled: true,
      ),
      // first name
      _buildEditableRow(
        'First Name',
        controller.flowDetectController.firstNameEn,
        error: controller.flowDetectController.firstNameEnError,
        isDisabled: true,
      ),
      // last name
      _buildEditableRow(
        'Last Name',
        controller.flowDetectController.lastNameEn,
        error: controller.flowDetectController.lastNameEnError,
        isDisabled: true,
      ),
      // date of birth
      _buildEditableRow(
        'Date of Birth',
        controller.flowDetectController.dateOfBirthEn,
        error: controller.flowDetectController.dateOfBirthEnError,
        isDisabled: true,
      ),
      // date of issue
      _buildEditableRow(
        'Date of Issue',
        controller.flowDetectController.dateOfIssueEn,
        error: controller.flowDetectController.dateOfIssueEnError,
        isDisabled: true,
      ),
      // date of expiry
      _buildEditableRow(
        'Date of Expiry',
        controller.flowDetectController.dateOfExpiryEn,
        error: controller.flowDetectController.dateOfExpiryEnError,
        isDisabled: true,
      ),
    ],
  );
}

Widget _buildEditableRow(String label, RxString value,
    {RxString? error, bool isDisabled = false, bool isNumeric = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Obx(() {
          return TextFormField(
            controller: TextEditingController(text: value.value)
              ..selection = TextSelection.collapsed(offset: value.value.length),
            onChanged: (text) {
              value.value = text;
            },
            readOnly: isDisabled,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Enter $label',
              errorText: error?.value.isEmpty ?? true ? null : error?.value,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            style: const TextStyle(fontSize: 16, color: Colors.black),
          );
        }),
      ],
    ),
  );
}
