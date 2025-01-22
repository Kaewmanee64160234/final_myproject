import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:identity_scan/app/modules/home/views/home_view.dart';
import 'package:identity_scan/app/routes/app_pages.dart';

import '../controllers/flow_detact_controller.dart';

class FlowDetactView extends GetView<FlowDetactController> {
  const FlowDetactView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'ขั้นตอนการลงทะเบียน',
          style: GoogleFonts.kanit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(3, 6, 80, 1),
      ),
      body: Obx(() {
        // Show loading indicator while API is active and data is still loading
        if (controller.isLoading.value || controller.isApiActive.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        }

        // Show registration steps when the app starts, and data is not yet loaded
        if (controller.idNumber.isEmpty ||
            controller.laserCodeOriginal.value.isEmpty) {
          return _buildRegistrationSteps(context);
        }

        // Show content in a SingleChildScrollView when data is loaded
        return SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04), // Dynamic padding
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                    controller.card.value.getDecodedPortrait(),
                  ),
                ),
                SizedBox(height: screenWidth * 0.04),
                const Divider(),
                Text(
                  'รายละเอียดบัตรประชาชน',
                  style: GoogleFonts.kanit(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildCardDetails(),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        // Display an empty SizedBox during loading
        if (controller.isLoading.value || controller.isApiActive.value) {
          return const SizedBox();
        } else {
          // Display bottom navigation bar after data is loaded
          return _buildBottomNavigationBar(context);
        }
      }),
    );
  }

  Widget _buildCardDetails() {
    return Column(
      children: [
        // แสดงรายละเอียดของบัตรประชาชน
        _buildEditableRow(
          'Card ID',
          controller.idNumber,
          error: controller.idNumberError,
          isDisabled: true,
        ),
        // prefix
        _buildEditableRow(
          'Prefix',
          controller.prefix,
          error: controller.prefixError,
          isDisabled: false,
        ),
        // first name
        _buildEditableRow(
          'First Name',
          controller.firstName,
          error: controller.firstNameError,
          isDisabled: false,
        ),
        // last name
        _buildEditableRow(
          'Last Name',
          controller.lastName,
          error: controller.lastNameError,
          isDisabled: false,
        ),
        // date of birth
        _buildEditableRow(
          'Date of Birth',
          controller.dateOfBirth,
          error: controller.dateOfBirthError,
          isDisabled: false,
        ),
        // date of issue
        _buildEditableRow(
          'Date of Issue',
          controller.dateOfIssue,
          error: controller.dateOfIssueError,
          isDisabled: false,
        ),
        // date of expiry
        _buildEditableRow(
          'Date of Expiry',
          controller.dateOfExpiry,
          error: controller.dateOfExpiryError,
          isDisabled: false,
        ),
        // religion
        _buildEditableRow(
          'Religion',
          controller.religion,
          error: controller.religionError,
          isDisabled: false,
        ),
        // address
        _buildEditableRow(
          'Address',
          controller.address,
          error: controller.addressError,
          isDisabled: false,
        ),
        Divider(),
        // header eng
        Text(
          'Thai ID Card Details',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        // eng detail card
        // prefix
        _buildEditableRow(
          'Prefix',
          controller.prefixEn,
          error: controller.prefixEnError,
          isDisabled: false,
        ),
        // first name
        _buildEditableRow(
          'First Name',
          controller.firstNameEn,
          error: controller.firstNameEnError,
          isDisabled: false,
        ),
        // last name
        _buildEditableRow(
          'Last Name',
          controller.lastNameEn,
          error: controller.lastNameEnError,
          isDisabled: false,
        ),
        // date of birth
        _buildEditableRow(
          'Date of Birth',
          controller.dateOfBirthEn,
          error: controller.dateOfBirthEnError,
          isDisabled: false,
        ),
        // date of issue
        _buildEditableRow(
          'Date of Issue',
          controller.dateOfIssueEn,
          error: controller.dateOfIssueEnError,
          isDisabled: false,
        ),
        // date of expiry
        _buildEditableRow(
          'Date of Expiry',
          controller.dateOfExpiryEn,
          error: controller.dateOfExpiryEnError,
          isDisabled: false,
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
                ..selection =
                    TextSelection.collapsed(offset: value.value.length),
              onChanged: (text) {
                value.value = text;

                // Validate dynamically
                if (label == 'Card ID') {
                  error?.value = controller.validateIdCard(value.value)
                      ? '' // Valid input
                      : 'Invalid Card ID (must be 13 digits)';
                } else if (text.isEmpty) {
                  error?.value = '$label is required';
                } else {
                  error?.value = ''; // Clear error if valid
                }
              },
              readOnly: isDisabled,
              keyboardType:
                  isNumeric ? TextInputType.number : TextInputType.text,
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

  Widget beautifulTextField({
    required String labelText,
    required String hintText,
    required TextEditingController controller,
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
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
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: const TextStyle(fontSize: 16, color: Colors.black),
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
          style: GoogleFonts.kanit(fontSize: screenWidth * 0.05),
        ),
        SizedBox(height: screenWidth * 0.05),
        StepWidget(
          step: 1,
          text: "ถ่ายภาพหน้าบัตรประชาชน",
        ),
        StepWidget(step: 2, text: "ถ่ายภาพหน้าบัตรประชาชน"),
        StepWidget(step: 3, text: "ถ่ายภาพหน้าตัวเอง"),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
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
              if (controller.similarity.value != 0) {
                // Congratulatory message with Clear Data button
                return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenWidth * 0.03, // Dynamic padding
                      ),
                    ),
                    onPressed: () {
                      Get.toNamed(Routes.MAPPING_FACE);
                    },
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ));
              } else if (controller.idNumber.isEmpty &&
                  controller.similarity.value == 0) {
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
                    controller.openCameraPage();
                    controller.isApiActive.value = true;
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
              } else if (controller.similarity.value != 0 &&
                  controller.similarity.value < 0.98) {
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
                          controller.validateFields();
                          if (controller.isValid.value) {
                            Get.toNamed(Routes.RESULT_OCR);
                          }
                        },
                        child: Text(
                          'ยืนยัน', // "Next"
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
                          controller.validateFields();
                          if (controller.isValid.value) {
                            controller.openScanFace();
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
}
