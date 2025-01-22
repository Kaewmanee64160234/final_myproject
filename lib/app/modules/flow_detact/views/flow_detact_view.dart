import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:identity_scan/app/modules/home/views/home_view.dart';

import '../controllers/flow_detact_controller.dart';

class FlowDetactView extends GetView<FlowDetactController> {
  const FlowDetactView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
        // ถ้า isLoading เป็น true แสดง loading indicator
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        }
        // ถ้า isLoading เป็น false แสดง SingleChildScrollView
        else {
          return SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.04), // Dynamic padding
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // แสดงรายละเอียดหากไม่มีการโหลด
                  if (controller.idNumber.isNotEmpty &&
                      controller.laserCodeOriginal.value.isNotEmpty)
                    Column(
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
                            controller.card.value.getDecodedPortrait(),
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.04),
                        _buildCardDetails(context),
                      ],
                    )
                  else
                    _buildRegistrationSteps(
                        context), // หากไม่มี card ID ให้แสดงขั้นตอนการลงทะเบียน
                ],
              ),
            ),
          );
        }
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value) {
          // ใส่เป็น sizedbox แทน Container เพราะใส่ Container แล้วมีปัญหา
          return SizedBox();
        } else {
          return _buildBottomNavigationBar(context);
        }
      }),
    );
  }

  Widget _buildCardDetails(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04), // Dynamic padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'บัตรประชาชนภาษาไทย',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          _buildEditableRow('Card ID', controller.idNumber, isDisabled: true),
          _buildEditableRow('Prefix', controller.prefix),
          _buildEditableRow('First Name', controller.fullName),
          _buildEditableRow('Last Name', controller.lastName),
          _buildEditableRow('Date of Birth', controller.dateOfBirth),
          _buildEditableRow('Date of Issue', controller.dateOfIssue),
          _buildEditableRow('Date of Expiry', controller.dateOfExpiry),
          _buildEditableRow('Address:', controller.address),
          SizedBox(height: screenWidth * 0.04),
          const Text(
            'บัตรประชาชน (EN)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          _buildEditableRow('Prefix', controller.prefixEn),
          _buildEditableRow('First Name', controller.firstNameEn),
          _buildEditableRow('Last Name', controller.lastNameEn),
          _buildEditableRow('Date of Birth', controller.dateOfBirthEn),
          _buildEditableRow('Date of Issue', controller.dateOfIssueEn),
          _buildEditableRow('Date of Expiry', controller.dateOfExpiryEn),
          SizedBox(height: screenWidth * 0.04),
          const Divider(),
          _buildEditableRow('Laser Code', controller.laserCodeOriginal),
          ElevatedButton(
            onPressed: () {
              BottomPicker.date(
                pickerTitle: Text(
                  'Set your Birthday',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.blue,
                  ),
                ),
                dateOrder: DatePickerDateOrder.dmy,
                initialDateTime: DateTime(1996, 10, 22),
                maxDateTime: DateTime(1998),
                minDateTime: DateTime(1980),
                pickerTextStyle: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                onChange: (index) {
                  print(index);
                },
                onSubmit: (index) {
                  print(index);
                },
                bottomPickerTheme: BottomPickerTheme.plumPlate,
              ).show(context);
            },
            child: Text('Set your Birthday'),
          )
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

  Widget _buildEditableRow(String label, RxString value,
      {bool isDate = false, bool isDisabled = false}) {
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
          const SizedBox(height: 4), // Spacing between label and field
          Obx(() {
            return TextFormField(
              enabled: !isDisabled,
              controller: TextEditingController(text: value.value)
                ..selection =
                    TextSelection.collapsed(offset: value.value.length),
              readOnly: isDate,
              onTap: isDate
                  ? () async {
                      // Open date picker if this field is a date
                      DateTime? pickedDate = await showDatePicker(
                        context: Get.context!,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900), // Minimum date
                        lastDate: DateTime.now(), // Maximum date
                      );
                      if (pickedDate != null) {
                        value.value =
                            '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                      }
                    }
                  : null,
              onChanged: isDate ? null : (text) => value.value = text,
              decoration: InputDecoration(
                hintText: isDate ? 'Select Date' : 'Enter $label',
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 255, 255),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade500, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            );
          }),
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
              } else if (controller.idNumber.isEmpty) {
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
