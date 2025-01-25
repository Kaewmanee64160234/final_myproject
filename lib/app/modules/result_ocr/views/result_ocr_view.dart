import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flip_card/flip_card.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:identity_scan/app/data/models/card_type.dart';
import 'package:identity_scan/app/modules/flow_detact/controllers/flow_detact_controller.dart';
import '../controllers/result_ocr_controller.dart';

class ResultOcrView extends GetView<ResultOcrController> {
  final ID_CARD card;
  const ResultOcrView({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlowDetactController flowDetactController = Get.put(FlowDetactController());
    ResultOcrController resultOcrController = Get.put(ResultOcrController());
    final localTheme = ThemeData(
      textTheme: GoogleFonts.notoSerifThaiTextTheme(
        Theme.of(context).textTheme,
      ),
    );
    return Theme(
      data: localTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('The result of OCR'),
          centerTitle: true,
          automaticallyImplyLeading: false, // เอาปุ่มย้อนกลับออก
          backgroundColor: const Color.fromRGBO(45, 56, 146, 1),
          foregroundColor: Colors.white,
        ),
        body: Container(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            height: 250,
            width: 350,
            child: FlipCard(
              direction: FlipDirection.HORIZONTAL,
              side: CardSide.FRONT,
              speed: 1000,
              onFlipDone: (status) {
                print(status);
              },
              front: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color.fromRGBO(170, 211, 231, 1)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Side: Images (Krut and Barcode)
                            Column(
                              children: [
                                // Krut Image
                                Container(
                                  padding: const EdgeInsets.all(
                                      2), // Padding between the border and CircleAvatar
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors
                                          .deepOrangeAccent, // Border color
                                      width: 0.5, // Border width
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      child: Image.asset(
                                        'assets/images/krut.png',
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Barcode Image
                                Image.asset(
                                  'assets/images/barcode.png',
                                  width: 20,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                            // const SizedBox(width: 8),
                            // Right Side: Card Information
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title and ID

                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Row(
                                      children: [
                                        Text(
                                          "บัตรประจำตัวประชาชน",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Thai National ID Card",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // ID Number
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "เลขประจำตัวประชาชน",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    9, 13, 134, 1),
                                              ),
                                            ),
                                            Text(
                                              "Identification Number",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    9, 13, 134, 1),
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "${card.idNumber.split('').sublist(0, 1).join()} ${card.idNumber.split('').sublist(1, 5).join()} ${card.idNumber.split('').sublist(5, 10).join()} ${card.idNumber.split('').sublist(10, 12).join()} ${card.idNumber.split('').sublist(12, 13).join()}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),

                                  // Name in Thai
                                  Row(
                                    children: [
                                      const Text(
                                        "ชื่อตัวและนามสกุล ",
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        card.th.prefix +
                                            card.th.name +
                                            " " +
                                            card.th.lastName,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),

                                  // Name in English
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                          'assets/images/chipcard_nobg.png',
                                          width: 50,
                                          height: 50),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(width: 16),
                                              const Text(
                                                "Name",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromRGBO(
                                                        9, 13, 134, 1)),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "${card.en.prefix} ${card.en.name}",
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Color.fromRGBO(
                                                        9, 13, 134, 1)),
                                              ),
                                            ],
                                          ),
                                          // last name
                                          Row(
                                            children: [
                                              SizedBox(width: 16),
                                              const Text(
                                                "Last Name",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromRGBO(
                                                        9, 13, 134, 1)),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                card.en.lastName,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Color.fromRGBO(
                                                        9, 13, 134, 1)),
                                              ),
                                            ],
                                          ), // Date of Birth
                                          Row(
                                            children: [
                                              const SizedBox(width: 32),
                                              const Text(
                                                "วันเกิด:",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                card.th.dateOfBirth,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const SizedBox(width: 32),
                                              const Text(
                                                "Date of Birth:",
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromRGBO(
                                                        9, 13, 134, 1)),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                card.en.dateOfBirth,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromRGBO(
                                                        9, 13, 134, 1)),
                                              ),
                                            ],
                                          ),
                                          // ศาสนา
                                          Row(
                                            children: [
                                              const SizedBox(width: 32),
                                              const Text(
                                                "ศาสนา:",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                card.th.religion,
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // Address
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Left column for address and dates
                                        Expanded(
                                          flex:
                                              2, // Ensures the address takes up 50% of the row
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Address with dynamic line break for "อ."
                                              Text(
                                                "ที่อยู่ " +
                                                    _formatAddressWithLineBreak(
                                                        card.th.address
                                                            .province),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines:
                                                    2, // Limits the address to two lines
                                                overflow: TextOverflow
                                                    .ellipsis, // Adds ellipsis if text overflows
                                                softWrap:
                                                    true, // Allows text to wrap
                                              ),
                                              const SizedBox(height: 2),
                                              // Dates
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Date of Issue
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        card.th.dateOfIssue,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 8),
                                                      ),
                                                      const Text(
                                                        "วันออกบัตร",
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        card.en.dateOfIssue,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Color.fromRGBO(
                                                                    9,
                                                                    13,
                                                                    134,
                                                                    1),
                                                            fontSize: 8),
                                                      ),
                                                      const Text(
                                                        "Date of Issue",
                                                        style: TextStyle(
                                                            fontSize: 8,
                                                            color:
                                                                Color.fromRGBO(
                                                                    9,
                                                                    13,
                                                                    134,
                                                                    1),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                      width:
                                                          70), // Spacing between columns
                                                  // Date of Expiry
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        card.th.dateOfExpiry,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 8),
                                                      ),
                                                      const Text(
                                                        "วันหมดอายุ",
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        card.en.dateOfExpiry,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Color.fromRGBO(
                                                                    9,
                                                                    13,
                                                                    134,
                                                                    1),
                                                            fontSize: 8),
                                                      ),
                                                      const Text(
                                                        "Date of Expiry",
                                                        style: TextStyle(
                                                            fontSize: 8,
                                                            color:
                                                                Color.fromRGBO(
                                                                    9,
                                                                    13,
                                                                    134,
                                                                    1),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Image.memory(
                              base64Decode(card.portrait),
                              // height:
                              //     90, // Adjusts to 50% of the card height
                              width: 70, // Keeps the aspect ratio
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 8),
                            const Text("1302-04-11240912",
                                style: TextStyle(
                                    fontSize: 9, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  )),
              back: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color.fromRGBO(170, 211, 231, 1)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 32),
                          child: Column(
                            children: [
                              Text("ปรเทศไทย",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Color.fromRGBO(0, 0, 0, 1),
                                    fontWeight: FontWeight.bold,
                                  )),
                              Image.asset(
                                'assets/images/th_flag.png',
                                width: 40,
                                height: 30,
                                fit: BoxFit.cover,
                              ),
                              // THAILAND
                              Text("THAILAND",
                                  style: TextStyle(
                                    fontSize: 7,
                                    color: Color.fromRGBO(0, 0, 0, 1),
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${card.laserCode.split('').sublist(0, 3).join()}-${card.laserCode.split('').sublist(3, 10).join()}-${card.laserCode.split('').sublist(10, 12).join()}",
                      style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 114, 114, 114),
                          fontWeight: FontWeight.w100),
                    ),
                    ThaiDatePicker(
                      initialDate: DateTime.now(),
                      onDateChanged: (DateTime? date) {
                        print(date);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Button at the bottom
      ),
    );
  }
}

String _formatAddressWithLineBreak(String address) {
  // Check if "อ." exists in the address
  if (address.contains("อ.")) {
    // Insert a line break before "อ."
    return address.replaceFirst("อ.", "\nอ.");
  }
  return address; // Return the original address if "อ." is not found
}

class ThaiDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime?> onDateChanged;

  const ThaiDatePicker({
    Key? key,
    required this.initialDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  _ThaiDatePickerState createState() => _ThaiDatePickerState();
}

class _ThaiDatePickerState extends State<ThaiDatePicker> {
  late int? selectedDay;
  late int? selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedDay = widget.initialDate.day != 0 ? widget.initialDate.day : null;
    selectedMonth =
        widget.initialDate.month != 0 ? widget.initialDate.month : null;
    selectedYear = widget.initialDate.year + 543; // Convert to พ.ศ.
  }

  @override
  Widget build(BuildContext context) {
    final int currentYear = DateTime.now().year + 543; // Current year in พ.ศ.

    return SizedBox(
      height: 250,
      child: Row(
        children: [
          // Day Picker
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: selectedDay == null ? 0 : selectedDay!,
              ),
              itemExtent: 40,
              onSelectedItemChanged: (int index) {
                setState(() {
                  selectedDay = index == 0 ? null : index;
                  _onDateChanged();
                });
              },
              children: [
                const Center(
                    child: Text("ไม่ระบุ", style: TextStyle(fontSize: 18))),
                ...List.generate(
                  31,
                  (index) => Center(
                      child: Text('${index + 1}',
                          style: const TextStyle(fontSize: 18))),
                ),
              ],
            ),
          ),
          // Month Picker
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: selectedMonth == null ? 0 : selectedMonth!,
              ),
              itemExtent: 40,
              onSelectedItemChanged: (int index) {
                setState(() {
                  selectedMonth = index == 0 ? null : index;
                  _onDateChanged();
                });
              },
              children: [
                const Center(
                    child: Text("ไม่ระบุ", style: TextStyle(fontSize: 18))),
                ...List.generate(
                  12,
                  (index) => Center(
                      child: Text(_monthName(index + 1),
                          style: const TextStyle(fontSize: 18))),
                ),
              ],
            ),
          ),
          // Year Picker
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: selectedYear -
                    (currentYear - 200), // Adjust scroll position
              ),
              itemExtent: 40,
              onSelectedItemChanged: (int index) {
                setState(() {
                  selectedYear = (currentYear - 200) + index;
                  _onDateChanged();
                });
              },
              children: List.generate(
                201,
                (index) => Center(
                    child: Text('${(currentYear - 200) + index}',
                        style: const TextStyle(fontSize: 18))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDateChanged() {
    // Return null for incomplete dates
    if (selectedDay == null || selectedMonth == null) {
      widget.onDateChanged(null);
    } else {
      final gregorianYear = selectedYear - 543; // Convert พ.ศ. to ค.ศ.
      widget
          .onDateChanged(DateTime(gregorianYear, selectedMonth!, selectedDay!));
    }
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
