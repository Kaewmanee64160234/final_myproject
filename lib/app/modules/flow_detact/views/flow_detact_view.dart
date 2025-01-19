import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/flow_detact_controller.dart';

class FlowDetactView extends GetView<FlowDetactController> {
  const FlowDetactView({super.key});

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const CircularProgressIndicator();
            } else if (controller.card.value.idNumber.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Display card portrait in a circle
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: MemoryImage(
                      controller.card.value.getDecodedPortrait(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Display LaserCode
                  Text(
                    'LaserCode: ${controller.laserCodeOriginal.value}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Card details in a Card widget
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'บัตรประชาชน (TH)',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Divider(),
                          _buildInfoRow(
                              'Card ID:', controller.card.value.idNumber),
                          _buildInfoRow('Full Name (TH):',
                              controller.card.value.th.fullName),
                          _buildInfoRow(
                              'Prefix (TH):', controller.card.value.th.prefix),
                          _buildInfoRow(
                              'Name (TH):', controller.card.value.th.name),
                          _buildInfoRow('Last Name (TH):',
                              controller.card.value.th.lastName),
                          _buildInfoRow('Date of Birth (TH):',
                              controller.card.value.th.dateOfBirth),
                          _buildInfoRow('Date of Issue (TH):',
                              controller.card.value.th.dateOfIssue),
                          _buildInfoRow('Date of Expiry (TH):',
                              controller.card.value.th.dateOfExpiry),
                          _buildInfoRow('Religion (TH):',
                              controller.card.value.th.religion),
                          _buildInfoRow('Address (TH):',
                              controller.card.value.th.address.full),
                          const Divider(),
                          Text(
                            'บัตรประชาชน (EN)',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Divider(),
                          _buildInfoRow('Full Name (EN):',
                              controller.card.value.en.fullName),
                          _buildInfoRow(
                              'Prefix (EN):', controller.card.value.en.prefix),
                          _buildInfoRow(
                              'Name (EN):', controller.card.value.en.name),
                          _buildInfoRow('Last Name (EN):',
                              controller.card.value.en.lastName),
                          _buildInfoRow('Date of Birth (EN):',
                              controller.card.value.en.dateOfBirth),
                          _buildInfoRow('Date of Issue (EN):',
                              controller.card.value.en.dateOfIssue),
                          _buildInfoRow('Date of Expiry (EN):',
                              controller.card.value.en.dateOfExpiry),
                          _buildInfoRow('Religion (EN):',
                              controller.card.value.en.religion),
                          _buildInfoRow('Address (EN):',
                              controller.card.value.en.address.full),
                          Divider()
                          // show similarity
                          ,
                          Text(
                            'Similarity: ${controller.similarity.value.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const Text(
                'FlowDetactView is working',
                style: TextStyle(fontSize: 20),
              );
            }
          }),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(3, 6, 80, 1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Center(
          child: Column(
            children: [
              Obx(() {
                return Column(
                  children: [
                    if (controller.card.value.idNumber.length == 0)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          controller.openCameraPage();
                        },
                        child: Text(
                          'เริ่มต้น',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              controller.openScanFace();
                            },
                            child: Text(
                              'ต่อไป',
                              style: const TextStyle(
                                fontSize: 18,
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
                            onPressed: () {
                              controller.clearDataForNewOCR();
                            },
                            child: Text(
                              'Clear Data',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 10),
                  ],
                );
              }),
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildInfoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
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
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
