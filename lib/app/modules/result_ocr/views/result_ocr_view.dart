import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flip_card/flip_card.dart';
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
        body: Center(
          child: SizedBox(
            height: 210,
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
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with logo and text
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(
                                2), // Padding between the border and CircleAvatar
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.deepOrange, // Border color
                                width: 0.5, // Border width
                              ),
                            ),
                            child: ClipOval(
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Image.asset(
                                  'assets/images/krut.png',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "บัตรประจำตัวประชาชน",
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Thai National ID Card",
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              // show id number
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "เลขประจำตัวประชาชน",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color.fromRGBO(9, 13, 134, 1),
                                        ),
                                      ),
                                      Text(
                                        "Identification Number",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color.fromRGBO(9, 13, 134, 1),
                                        ),
                                      )
                                    ],
                                  ),
                                  Text(
                                    card.idNumber,
                                  )
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // ID Number
                      Row(
                        children: [
                          const Text(
                            "เลขประจำตัวประชาชน:",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            flowDetactController.card.value.idNumber,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const Divider(),
                      // Full Name
                      Row(
                        children: [
                          const Text(
                            "ชื่อ-นามสกุล:",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              flowDetactController.card.value.th.fullName,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      // English Name
                      Row(
                        children: [
                          const Text(
                            "Name:",
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(9, 13, 134, 1)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${flowDetactController.card.value.en.prefix} ${flowDetactController.card.value.en.name}",
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(9, 13, 134, 1)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Last Name
                      Row(
                        children: [
                          const Text(
                            "Last Name:",
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(9, 13, 134, 1)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            flowDetactController.card.value.en.lastName,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(9, 13, 134, 1)),
                          ),
                        ],
                      ),
                      const Divider(),
                      // Date of Birth
                      Row(
                        children: [
                          const Text(
                            "วันเกิด:",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            flowDetactController.card.value.th.dateOfBirth,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            "Date of Birth:",
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(9, 13, 134, 1)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            flowDetactController.card.value.en.dateOfBirth,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(9, 13, 134, 1)),
                          ),
                        ],
                      ),
                      const Divider(),
                      // Address
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ที่อยู่:",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            flowDetactController.card.value.th.address.full,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Chip and Flag
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'assets/images/chipcard_nobg.png',
                            width: 50,
                            height: 50,
                          ),
                          Column(
                            children: [
                              const Text(
                                "ประเทศไทย",
                                style: TextStyle(fontSize: 12),
                              ),
                              Image.asset(
                                'assets/images/th_flag.png',
                                width: 35,
                                height: 25,
                              ),
                              const Text(
                                "THAILAND",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color.fromRGBO(9, 13, 134, 1)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
                child: const Center(
                  child: Text(
                    "Back of Card",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
