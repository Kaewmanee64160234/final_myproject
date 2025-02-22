import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:identity_scan/app/modules/home/views/home_view.dart';
import 'package:identity_scan/app/routes/app_pages.dart';
import 'package:intl/intl.dart';

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
                _buildCardDetails(context),
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

  Widget _buildCardDetails(BuildContext context) {
    return Column(
      children: [
        // แสดงรายละเอียดของบัตรประชาชน
        _buildEditableRow(
            'เลขบัตรประชาชน', // Card ID
            controller.idNumber,
            error: controller.idNumberError,
            isDisabled: true,
            isEnglish: false,
            contextf: context),
        // คำนำหน้า
        _buildEditableRow(
          'คำนำหน้า', // Label for Prefix
          controller.prefix, // Observable for storing selected value
          error: controller.prefixError, // Observable for validation error
          isDisabled: false, // Enable/Disable dropdown
          isEnglish: false,
          contextf: context,
        ),
        // // ชื่อ
        _buildEditableRow(
            'ชื่อ', // First Name
            controller.firstName,
            error: controller.firstNameError,
            isDisabled: false,
            isEnglish: false,
            contextf: context),
        // // นามสกุล
        _buildEditableRow(
            'นามสกุล', // Last Name
            controller.lastName,
            error: controller.lastNameError,
            isDisabled: false,
            isEnglish: false,
            contextf: context),
        // // วันเกิด
        _buildEditableRow(
            'วันเดือนปีเกิด', // Date of Birth
            controller.dateOfBirth,
            error: controller.dateOfBirthError,
            isDisabled: false,
            isEnglish: false,
            contextf: context,
            isBirthDate: true,
            isDate: true),
        // // วันที่ออกบัตร
        _buildEditableRow(
            'วันที่ออกบัตร', // Date of Issue
            controller.dateOfIssue,
            error: controller.dateOfIssueError,
            isDisabled: false,
            contextf: context,
            isEnglish: false,
            isIssueDate: true,
            isDate: true),

        // // วันหมดอายุ
        _buildEditableRow(
            'วันหมดอายุ', // Date of Expiry
            controller.dateOfExpiry,
            error: controller.dateOfExpiryError,
            isDateExpiry: true,
            isDisabled: false,
            isEnglish: false,
            contextf: context,
            isDate: true),

        // // ศาสนา
        _buildEditableRow(
          'ศาสนา', // Religion
          controller.religion,
          error: controller.religionError,
          isDisabled: false,
          isEnglish: false,

          contextf: context,
        ),
        // // ที่อยู่
        _buildEditableRow(
          'ที่อยู่', // Address
          controller.address,
          error: controller.addressError,
          isDisabled: false,
          isEnglish: false,

          contextf: context,
        ),

        Divider(),
        // // header eng
        Text(
          'รายละเอียดบัตรประชาชนภาษาอังกฤษ', // Thai ID Card Details (English)
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        // // eng detail card
        // // คำนำหน้า (ภาษาอังกฤษ)
        _buildEditableRow(
          'คำนำหน้า (ภาษาอังกฤษ)', // Prefix (English)
          controller.prefixEn,
          error: controller.prefixEnError,
          isDisabled: false,
          isEnglish: true,

          contextf: context,
        ),
        // // ชื่อ (ภาษาอังกฤษ)
        _buildEditableRow(
          'ชื่อ (ภาษาอังกฤษ)', // First Name (English)
          controller.firstNameEn,
          error: controller.firstNameEnError,
          isDisabled: false,
          isEnglish: true,

          contextf: context,
        ),
        // // นามสกุล (ภาษาอังกฤษ)
        _buildEditableRow(
          'นามสกุล (ภาษาอังกฤษ)', // Last Name (English)
          controller.lastNameEn,
          error: controller.lastNameEnError,
          isDisabled: false,
          isEnglish: true,

          contextf: context,
        ),
        // // วันเกิด (ภาษาอังกฤษ)
        _buildEditableRow(
            'วันเดือนปีเกิด (ภาษาอังกฤษ)', // Date of Birth (English)
            controller.dateOfBirthEn,
            error: controller.dateOfBirthEnError,
            isDisabled: false,
            contextf: context,
            isBirthDate: true,
            isDate: true,
            isEnglish: true),
        // // วันที่ออกบัตร (ภาษาอังกฤษ)
        _buildEditableRow(
            'วันที่ออกบัตร (ภาษาอังกฤษ)', // Date of Issue (English)
            controller.dateOfIssueEn,
            error: controller.dateOfIssueEnError,
            isDisabled: false,
            contextf: context,
            isIssueDate: true,
            isDate: true,
            isEnglish: true),
        // // วันหมดอายุ (ภาษาอังกฤษ)
        _buildEditableRow(
            'วันหมดอายุ (ภาษาอังกฤษ)', // Date of Expiry (English)
            controller.dateOfExpiryEn,
            error: controller.dateOfExpiryEnError,
            isDateExpiry: true,
            isDisabled: false,
            contextf: context,
            isDate: true,
            isEnglish: true),
      ],
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
        StepWidget(step: 2, text: "ถ่ายภาพหลังบัตรประชาชน"),
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
                  controller.similarity.value < 0.90) {
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

  Widget _buildEditableRow(
    String label,
    RxString value, {
    RxString? error,
    bool isDisabled = false,
    bool isNumeric = false,
    bool? isDate,
    required BuildContext contextf,
    required bool isEnglish,
    bool? isBirthDate,
    bool? isIssueDate,
    bool? isDateExpiry,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          if (label == 'คำนำหน้า') // Check if the row is for the prefix
            Obx(() {
              final List<String> prefixes = [
                'นาย',
                'น.ส.',
                'นาง',
                'ด.ญ',
                'ด.ช.'
              ];

              // Ensure value is valid
              final selectedValue =
                  prefixes.contains(value.value) ? value.value : null;

              return DropdownButtonFormField<String>(
                value: selectedValue,
                items: prefixes
                    .map((prefix) => DropdownMenuItem(
                          value: prefix,
                          child: Text(prefix),
                        ))
                    .toList(),
                onChanged: isDisabled
                    ? null
                    : (selected) {
                        if (selected != null) {
                          value.value = selected;
                        }
                      },
                decoration: InputDecoration(
                  hintText: 'เลือก $label',
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
              );
            })
          else if (label == 'คำนำหน้า (ภาษาอังกฤษ)')
            Obx(() {
              final List<String> prefixes = [
                'Mr.',
                'Ms.',
                'Mrs.',
                'Miss',
                'Master'
              ];

              // Ensure value is valid
              final selectedValue =
                  prefixes.contains(value.value) ? value.value : null;

              return DropdownButtonFormField<String>(
                value: selectedValue,
                items: prefixes
                    .map((prefix) => DropdownMenuItem(
                          value: prefix,
                          child: Text(prefix),
                        ))
                    .toList(),
                onChanged: isDisabled
                    ? null
                    : (selected) {
                        if (selected != null) {
                          value.value = selected;
                        }
                      },
                decoration: InputDecoration(
                  hintText: 'Select $label',
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
              );
            })
          else if (label == 'ศาสนา')
            Obx(() {
              final List<String> religions = [
                'พุทธ',
                'คริสต์',
                'อิสลาม',
                'ฮินดู',
                'ยิว',
                'ไม่นับถือศาสนา',
              ];

              // Ensure value is valid
              final selectedValue =
                  religions.contains(value.value) ? value.value : null;

              return DropdownButtonFormField<String>(
                value: selectedValue,
                items: religions
                    .map((religion) => DropdownMenuItem(
                          value: religion,
                          child: Text(religion),
                        ))
                    .toList(),
                onChanged: isDisabled
                    ? null
                    : (selected) {
                        if (selected != null) {
                          value.value = selected;
                        }
                      },
                decoration: InputDecoration(
                  hintText: 'เลือก $label',
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
              );
            })
          else
            Obx(() {
              return TextFormField(
                controller: TextEditingController(text: value.value)
                  ..selection =
                      TextSelection.collapsed(offset: value.value.length),
                onChanged: (text) {
                  value.value = text;
                },
                readOnly: isDisabled || isDate == true,
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
                onTap: isDate == true && !isDisabled
                    ? () async {
                        print("value: ${value.value}");
                        // Parse the date from the text field
                        final initialDate = _getDateFromField(
                          value.value,
                          isThaiYear: !isEnglish,
                        );
                        // set selected date year month day
                        // chck year is thai or english
                        print("initialDate: $initialDate");
                        if (!isEnglish) {
                          controller.selectedYear.value =
                              initialDate.year + 543;
                        } else {
                          controller.selectedYear.value = initialDate.year;
                        }

                        controller.selectedMonth.value = initialDate.month;
                        controller.selectedDay.value = initialDate.day;

                        showModalBottomSheet(
                          context: contextf,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return ThaiDatePicker(
                                initialDate: initialDate,
                                isBirthDate: isBirthDate ?? false,
                                isIssueDate: isIssueDate ?? false,
                                isDateExpiry: isDateExpiry ?? false,
                                isThaiYear: !isEnglish,
                                onDateChanged: (selectedDate) {
                                  if (selectedDate == null) {
                                    // Handle the "Unknown" case
                                    value.value = isEnglish
                                        ? "Unknown date"
                                        : "ไม่ระบุวันที่";
                                  } else {
                                    // Format and update the selected date
                                    final dayText =
                                        (controller.selectedDay.value == 0 ||
                                                controller
                                                        .selectedMonth.value ==
                                                    0 ||
                                                (controller.selectedDay.value ==
                                                        1 &&
                                                    controller.selectedMonth
                                                            .value ==
                                                        0))
                                            ? (isEnglish
                                                ? "Unknown day"
                                                : "ไม่ระบุวัน")
                                            : "${selectedDate.day}";

                                    final monthText = controller
                                                .selectedMonth ==
                                            0
                                        ? (isEnglish
                                            ? "Unknown month"
                                            : "ไม่ระบุเดือน")
                                        : (isEnglish
                                            ? "${DateFormat.MMM('en_EN').format(selectedDate)}."
                                            : DateFormat.MMM('th_TH')
                                                .format(selectedDate));
                                    final yearText = isEnglish
                                        ? "${selectedDate.year}"
                                        : "${selectedDate.year}";

                                    value.value =
                                        "$dayText $monthText $yearText";
                                  }
                                });
                          },
                        );
                      }
                    : null,
              );
            }),
        ],
      ),
    );
  }
}

class ThaiDatePicker extends StatelessWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime?> onDateChanged;
  final bool isBirthDate;
  final bool isIssueDate;
  final bool isDateExpiry;
  final bool isThaiYear;

  ThaiDatePicker({
    Key? key,
    required this.initialDate,
    required this.onDateChanged,
    this.isBirthDate = false,
    this.isIssueDate = false,
    this.isDateExpiry = false,
    this.isThaiYear = true,
  }) : super(key: key);

  final FlowDetactController controller = Get.put(FlowDetactController());

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final currentThaiYear = currentYear + 543;

    final minYear = isBirthDate || isIssueDate
        ? currentThaiYear - 150
        : currentThaiYear - 150;
    final maxYear = isBirthDate || isDateExpiry
        ? currentThaiYear
        : (isIssueDate ? currentThaiYear : currentThaiYear + 150);

    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: Obx(() {
              return Row(
                children: [
                  // Day Picker
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: controller
                            .selectedDay.value, // Handle "Unknown day"
                      ),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        controller
                            .updateDay(index); // Adjust day based on index
                        onDateChanged(
                            controller.getSelectedDate(isThaiYear: isThaiYear));
                      },
                      children: [
                        const Center(
                          child: Text("ไม่ระบุวัน",
                              style: TextStyle(fontSize: 18)),
                        ),
                        ...List.generate(
                          31,
                          (index) => Center(
                            child: Text('${index + 1}',
                                style: const TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: controller
                            .selectedMonth.value, // Handle "Unknown month"
                      ),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        controller
                            .updateMonth(index); // Adjust month based on index
                        onDateChanged(
                            controller.getSelectedDate(isThaiYear: isThaiYear));
                      },
                      children: [
                        const Center(
                          child: Text("ไม่ระบุเดือน",
                              style: TextStyle(fontSize: 18)),
                        ),
                        ...List.generate(
                          12,
                          (index) => Center(
                            child: Text(_monthName(index + 1),
                                style: const TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: controller.selectedYear.value - minYear,
                      ),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        controller.updateYear(minYear + index);
                        onDateChanged(
                            controller.getSelectedDate(isThaiYear: isThaiYear));
                      },
                      children: List.generate(
                        maxYear - minYear + 1,
                        (index) => Center(
                          child: Text('${minYear + index}',
                              style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          CupertinoButton(
            child: const Text('ตกลง', style: TextStyle(fontSize: 18)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const monthNames = [
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม',
    ];
    return monthNames[month - 1];
  }
}

DateTime _getDateFromField(String? dateText, {bool isThaiYear = true}) {
  try {
    if (dateText == null || dateText.isEmpty) return DateTime.now();

    // Define a map for both full and abbreviated Thai and English months
    final months = {
      // Thai full and abbreviated month names
      'มกราคม': 1,
      'กุมภาพันธ์': 2,
      'มีนาคม': 3,
      'เมษายน': 4,
      'พฤษภาคม': 5,
      'มิถุนายน': 6,
      'กรกฎาคม': 7,
      'สิงหาคม': 8,
      'กันยายน': 9,
      'ตุลาคม': 10,
      'พฤศจิกายน': 11,
      'ธันวาคม': 12,
      'ม.ค.': 1,
      'ก.พ.': 2,
      'มี.ค.': 3,
      'เม.ย.': 4,
      'พ.ค.': 5,
      'มิ.ย.': 6,
      'ก.ค.': 7,
      'ส.ค.': 8,
      'ก.ย.': 9,
      'ต.ค.': 10,
      'พ.ย.': 11,
      'ธ.ค.': 12,
      // English abbreviated month names
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
      'Jan.': 1,
      'Feb.': 2,
      'Mar.': 3,
      'Apr.': 4,
      'May.': 5,
      'Jun.': 6,
      'Jul.': 7,
      'Aug.': 8,
      'Sep.': 9,
      'Oct.': 10,
      'Nov.': 11,
      'Dec.': 12,
    };

    // Split the input into parts
    final parts = dateText.split(' ');
    if (parts.length != 3) throw FormatException('Invalid date format');

    // Parse day, month, and year
    final day = int.tryParse(parts[0]) ?? 0; // Default to 0 if day is invalid
    final month = months[parts[1]]; // Look up the month from the map
    var year = int.tryParse(parts[2]) ?? 0; // Default to 0 if year is invalid

    print("Parsed day: $day, month: $month, year: $year");

    // Ensure month and year are valid
    if (month == null || year <= 0)
      throw FormatException('Invalid date format');

    // Adjust the year for Thai Buddhist calendar if necessary
    print("isThaiYear: $isThaiYear");
    if (!isThaiYear && year > 0) {
      year += 543; // Convert Buddhist year to Gregorian
      print("Converted Thai year to Gregorian: $year");
    } else if (isThaiYear && year > 0) {
      year -= 543;
    }

    // Return the constructed DateTime object
    return DateTime(year, month, day);
  } catch (e) {
    print("Error parsing date: $e");
    return DateTime.now(); // Fallback to current date on error
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
      padding: const EdgeInsets.only(left: 15, top: 8.0, bottom: 8.0),
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

class PrefixDropdown extends StatelessWidget {
  final RxString selectedPrefix = ''.obs;

  PrefixDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> prefixes = ['นาย', 'น.ส.', 'นาง', 'ด.ช.', 'ด.ญ.'];

    return Obx(() {
      return DropdownButtonFormField<String>(
        value: selectedPrefix.value.isEmpty ? null : selectedPrefix.value,
        items: prefixes
            .map((prefix) => DropdownMenuItem(
                  value: prefix,
                  child: Text(prefix),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            selectedPrefix.value = value;
          }
        },
        decoration: InputDecoration(
          labelText: 'คำนำหน้า',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      );
    });
  }
}
