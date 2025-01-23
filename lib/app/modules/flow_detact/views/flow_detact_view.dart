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
        foregroundColor: Colors.white,
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
          'เลขบัตรประชาชน', // Card ID
          controller.idNumber,
          error: controller.idNumberError,
          isDisabled: true,
        ),
        // คำนำหน้า
        _buildEditableRow(
          'คำนำหน้า', // Prefix
          controller.prefix,
          error: controller.prefixError,
          isDisabled: false,
        ),
        // ชื่อ
        _buildEditableRow(
          'ชื่อ', // First Name
          controller.firstName,
          error: controller.firstNameError,
          isDisabled: false,
        ),
        // นามสกุล
        _buildEditableRow(
          'นามสกุล', // Last Name
          controller.lastName,
          error: controller.lastNameError,
          isDisabled: false,
        ),
        // วันเกิด
        _buildEditableRow(
          'วันเดือนปีเกิด', // Date of Birth
          controller.dateOfBirth,
          error: controller.dateOfBirthError,
          isDisabled: false,
        ),
        // วันที่ออกบัตร
        _buildEditableRow(
          'วันที่ออกบัตร', // Date of Issue
          controller.dateOfIssue,
          error: controller.dateOfIssueError,
          isDisabled: false,
        ),
        // วันหมดอายุ
        _buildEditableRow(
          'วันหมดอายุ', // Date of Expiry
          controller.dateOfExpiry,
          error: controller.dateOfExpiryError,
          isDisabled: false,
        ),
        // ศาสนา
        _buildEditableRow(
          'ศาสนา', // Religion
          controller.religion,
          error: controller.religionError,
          isDisabled: false,
        ),
        // ที่อยู่
        _buildEditableRow(
          'ที่อยู่', // Address
          controller.address,
          error: controller.addressError,
          isDisabled: false,
        ),
        Divider(),
        // header eng
        Text(
          'รายละเอียดบัตรประชาชนภาษาอังกฤษ', // Thai ID Card Details (English)
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        // eng detail card
        // คำนำหน้า (ภาษาอังกฤษ)
        _buildEditableRow(
          'คำนำหน้า (ภาษาอังกฤษ)', // Prefix (English)
          controller.prefixEn,
          error: controller.prefixEnError,
          isDisabled: false,
        ),
        // ชื่อ (ภาษาอังกฤษ)
        _buildEditableRow(
          'ชื่อ (ภาษาอังกฤษ)', // First Name (English)
          controller.firstNameEn,
          error: controller.firstNameEnError,
          isDisabled: false,
        ),
        // นามสกุล (ภาษาอังกฤษ)
        _buildEditableRow(
          'นามสกุล (ภาษาอังกฤษ)', // Last Name (English)
          controller.lastNameEn,
          error: controller.lastNameEnError,
          isDisabled: false,
        ),
        // วันเกิด (ภาษาอังกฤษ)
        _buildEditableRow(
          'วันเดือนปีเกิด (ภาษาอังกฤษ)', // Date of Birth (English)
          controller.dateOfBirthEn,
          error: controller.dateOfBirthEnError,
          isDisabled: false,
        ),
        // วันที่ออกบัตร (ภาษาอังกฤษ)
        _buildEditableRow(
          'วันที่ออกบัตร (ภาษาอังกฤษ)', // Date of Issue (English)
          controller.dateOfIssueEn,
          error: controller.dateOfIssueEnError,
          isDisabled: false,
        ),
        // วันหมดอายุ (ภาษาอังกฤษ)
        _buildEditableRow(
          'วันหมดอายุ (ภาษาอังกฤษ)', // Date of Expiry (English)
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
                            Get.toNamed(Routes.RESULT_OCR, arguments: {
                              'card': controller.card.value,
                            });
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
              }
              if (controller.validateIdCard(controller.card.value.idNumber) ==
                  false) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.15,
                      vertical: screenWidth * 0.03, // Dynamic padding
                    ),
                  ),
                  onPressed: () {
                    Get.offAll(() => HomeView());
                  },
                  child: Text(
                    'ข้อมูลไม่ถูกต้อง ลองอีกครั้ง', // "Start"
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
              style: GoogleFonts.kanit(
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
              style: GoogleFonts.kanit(
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
