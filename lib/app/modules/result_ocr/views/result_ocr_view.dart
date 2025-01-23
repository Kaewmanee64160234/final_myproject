import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flip_card/flip_card.dart';
import 'package:identity_scan/app/data/models/card_type.dart';
import 'package:identity_scan/app/modules/flow_detact/controllers/flow_detact_controller.dart';
import '../controllers/result_ocr_controller.dart';

class ResultOcrView extends GetView<ResultOcrController> {
  FlowDetactController flowDetactController = Get.put(FlowDetactController());

  // final ID_CARD? idCard;
  // ResultOcrView({Key? key, this.idCard}) : super(key: key);

  ResultOcrView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ResultOcrView'),
        centerTitle: true,
        automaticallyImplyLeading: false, // เอาปุ่มย้อนกลับออก
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              height: 230,
              width: 330,
              child: FlipCard(
                  direction: FlipDirection.HORIZONTAL,
                  side: CardSide.FRONT,
                  speed: 1000,
                  onFlipDone: (status) {
                    print(status);
                  },
                  front: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white, // สีด้านบน (สีขาว)
                              Color.fromRGBO(
                                  170, 211, 231, 1), // สีด้านล่าง (RGB)
                            ],
                            begin: Alignment.topCenter, // เริ่มจากด้านบน
                            end: Alignment.bottomCenter, // จบที่ด้านล่าง
                            stops: [
                              0.6,
                              0.6
                            ], // กำหนดตำแหน่งที่การไล่สีจะหยุด (60% ขาว, 40% RGB)
                          ),
                          border: Border.all(
                            color: Colors.black, // สีของขอบ
                            width: 0.5, // ความหนาของขอบ
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      ClipOval(
                                        child: Image.asset(
                                          'assets/images/krut.png',
                                          width: 33,
                                          height: 33,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Column(
                                          // กำหนดให้ text บัตรประชาชน 3 บรรทัด ชิดซ้าย
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "บัตรประจำตัวประชาชน",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "Thai National ID Card",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Color.fromRGBO(
                                                          9, 13, 134, 1)),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "เลขประจำตัวประชาชน",
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Identification Number",
                                                          style: TextStyle(
                                                              fontSize: 9,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      9,
                                                                      13,
                                                                      134,
                                                                      1)),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                    "${flowDetactController.card.value.idNumber}",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ))
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "ชื่อตัวและชื่อสกุล",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                      "${flowDetactController.card.value.th.fullName}")
                                ],
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/images/chipcard_nobg.png',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Name",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color.fromRGBO(
                                                      9, 13, 134, 1)),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              "${flowDetactController.card.value.en.prefix + flowDetactController.card.value.en.name}",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color.fromRGBO(
                                                      9, 13, 134, 1)),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Last name",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color.fromRGBO(
                                                      9, 13, 134, 1)),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              "${flowDetactController.card.value.en.lastName}",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color.fromRGBO(
                                                      9, 13, 134, 1)),
                                            )
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Row(
                                            children: [
                                              Text(
                                                "เกิดวันที่",
                                                style: TextStyle(fontSize: 10),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "${flowDetactController.card.value.th.dateOfBirth}",
                                                style: TextStyle(fontSize: 10),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Date of Birth",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Color.fromRGBO(
                                                        9, 13, 134, 1)),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "${flowDetactController.card.value.en.dateOfBirth}",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Color.fromRGBO(
                                                        9, 13, 134, 1)),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Row(
                                            children: [
                                              Text(
                                                "ศาสนา",
                                                style: TextStyle(fontSize: 10),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "${flowDetactController.card.value.th.religion}",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Color.fromRGBO(
                                                        9, 13, 134, 1)),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "ที่อยู่",
                                    style: TextStyle(fontSize: 9),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "${flowDetactController.card.value.th.address.full}",
                                    style: TextStyle(fontSize: 10),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      Row(children: [
                                        Text(
                                          "${flowDetactController.card.value.th.dateOfIssue}",
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ]),
                                      Row(children: [
                                        Text(
                                          "วันออกบัตร",
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ])
                                    ],
                                  ),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Column(
                                    children: [
                                      Row(children: [
                                        Text(
                                          "${flowDetactController.card.value.th.dateOfExpiry}",
                                          style: TextStyle(
                                            fontSize: 10,
                                          ),
                                        ),
                                      ]),
                                      Row(children: [
                                        Text(
                                          "วันบัตรหมดอายุ",
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ])
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        "${flowDetactController.card.value.en.dateOfIssue}",
                                        style: TextStyle(
                                            fontSize: 10,
                                            color:
                                                Color.fromRGBO(9, 13, 134, 1)),
                                      ),
                                      Text(
                                        "Date of Issue",
                                        style: TextStyle(
                                            fontSize: 10,
                                            color:
                                                Color.fromRGBO(9, 13, 134, 1)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        "${flowDetactController.card.value.en.dateOfExpiry}",
                                        style: TextStyle(
                                            fontSize: 10,
                                            color:
                                                Color.fromRGBO(9, 13, 134, 1)),
                                      ),
                                      Text(
                                        "Date of Expiry",
                                        style: TextStyle(
                                            fontSize: 10,
                                            color:
                                                Color.fromRGBO(9, 13, 134, 1)),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Image(
                          image: MemoryImage(
                            flowDetactController.card.value
                                .getDecodedPortrait(),
                          ),
                          width: 80,
                          // height: 100,
                        ),
                      ),
                    ],
                  ),
                  back: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white, // สีด้านบน (สีขาว)
                            Color.fromRGBO(
                                170, 211, 231, 1), // สีด้านล่าง (RGB)
                          ],
                          begin: Alignment.topCenter, // เริ่มจากด้านบน
                          end: Alignment.bottomCenter, // จบที่ด้านล่าง
                          stops: [
                            0.6,
                            0.6
                          ], // กำหนดตำแหน่งที่การไล่สีจะหยุด (60% ขาว, 40% RGB)
                        ),
                        border: Border.all(
                          color: Colors.black, // สีของขอบ
                          width: 0.5, // ความหนาของขอบ
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Positioned text in the center
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Centered Text',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          // Positioned image on the left
                          Positioned(
                            top: 120, // ตั้งค่าตำแหน่ง Y ของ image
                            left: 10, // ตั้งค่าตำแหน่ง X ของ image
                            child: Image.asset(
                              'assets/images/krut.png', // ใส่ path ของรูป
                              width: 40,
                              height: 40,
                            ),
                          ),
                          // Positioned image on the right
                          Positioned(
                              top: 80, // ตั้งค่าตำแหน่ง Y ของ image
                              right: 10, // ตั้งค่าตำแหน่ง X ของ image
                              child: Column(
                                children: [
                                  Text(
                                    "ประเทศไทย",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Image.asset(
                                    'assets/images/th_flag.png', // ใส่ path ของรูป
                                    // width: 40,
                                    height: 35,
                                  ),
                                  Text("THAILAND",
                                      style: TextStyle(fontSize: 12)),
                                ],
                              )),
                        ],
                      ))))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {}),
        child: Text("Hello"),
      ),
    );
  }
}
