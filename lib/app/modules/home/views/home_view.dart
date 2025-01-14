import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeView'),
        centerTitle: true,
      ),
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            children: [
              // Display status message dynamically
              Text(
                controller.statusMessage.value,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),

              // Button to call openCvView
              GestureDetector(
                onTap: () {
                  // Call the native method to open OpenCV view
                  controller.openOpenCVView();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: const Text(
                    'Open OpenCV View',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (controller.receivedData['typeofCard'] == '1')

                // Display image and other details if data is available
                if (controller.receivedData.isNotEmpty)
                  Column(
                    children: [
                      Text(
                        'Image Path: ${controller.receivedData['processedFile'] ?? "Not available"}',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      Text('SNR: ${controller.receivedData['snr'] ?? "N/A"}'),
                      Text(
                          'Brightness: ${controller.receivedData['brightness'] ?? "N/A"}'),
                      Text(
                          'Resolution: ${controller.receivedData['resolution'] ?? "N/A"}'),
                      const SizedBox(height: 10),

                      // Check for valid file path before displaying the image
                      if (controller.receivedData['processedFile'] != null &&
                          File(controller.receivedData['processedFile'])
                              .existsSync())
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.file(
                            File(controller.receivedData['processedFile']),
                            fit: BoxFit.cover,
                            width: 300,
                            height: 300,
                          ),
                        )
                      else
                        const Text(
                          'Image file not found.',
                          style: TextStyle(fontSize: 16),
                        ),
                      const Divider(),

                      // Display ID card details
                      Text(
                          'Card ID: ${controller.card.value.idNumber ?? "N/A"}'),
                      Text(
                          'Full Name (TH): ${controller.card.value.th.fullName ?? "N/A"}'),
                      Text(
                          'Prefix (TH): ${controller.card.value.th.prefix ?? "N/A"}'),
                      Text(
                          'Name (TH): ${controller.card.value.th.name ?? "N/A"}'),
                      Text(
                          'Last Name (TH): ${controller.card.value.th.lastName ?? "N/A"}'),
                      Text(
                          'Date of Birth (TH): ${controller.card.value.th.dateOfBirth ?? "N/A"}'),
                      Text(
                          'Date of Issue (TH): ${controller.card.value.th.dateOfIssue ?? "N/A"}'),
                      Text(
                          'Date of Expiry (TH): ${controller.card.value.th.dateOfExpiry ?? "N/A"}'),
                      Text(
                          'Religion (TH): ${controller.card.value.th.religion ?? "N/A"}'),
                      Text(
                          'Address (TH): ${controller.card.value.th.address.full ?? "N/A"}'),
                      const Divider(),
                      Text(
                          'Full Name (EN): ${controller.card.value.en.fullName ?? "N/A"}'),
                      Text(
                          'Prefix (EN): ${controller.card.value.en.prefix ?? "N/A"}'),
                      Text(
                          'Name (EN): ${controller.card.value.en.name ?? "N/A"}'),
                      Text(
                          'Last Name (EN): ${controller.card.value.en.lastName ?? "N/A"}'),
                      Text(
                          'Date of Birth (EN): ${controller.card.value.en.dateOfBirth ?? "N/A"}'),
                      Text(
                          'Date of Issue (EN): ${controller.card.value.en.dateOfIssue ?? "N/A"}'),
                      Text(
                          'Date of Expiry (EN): ${controller.card.value.en.dateOfExpiry ?? "N/A"}'),
                      Text(
                          'Religion (EN): ${controller.card.value.en.religion ?? "N/A"}'),
                      Text(
                          'Address (EN): ${controller.card.value.en.address.full ?? "N/A"}'),
                      Divider(),
                      // divider for orginal image
                      Text('Original Image'),
                      if (controller.receivedData['originalFile'] != null &&
                          File(controller.receivedData['originalFile'])
                              .existsSync())
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.file(
                            File(controller
                                .receivedData['originalSharpenedPath']),
                            fit: BoxFit.cover,
                            width: 300,
                            height: 300,
                          ),
                        ),
                      // cardOriginal
                      // Display ID card details
                      Text(
                          'Card ID: ${controller.cardOriginal.value.idNumber ?? "N/A"}'),
                      Text(
                          'Full Name (TH): ${controller.cardOriginal.value.th.fullName ?? "N/A"}'),
                      Text(
                          'Prefix (TH): ${controller.cardOriginal.value.th.prefix ?? "N/A"}'),
                      Text(
                          'Name (TH): ${controller.cardOriginal.value.th.name ?? "N/A"}'),
                      Text(
                          'Last Name (TH): ${controller.cardOriginal.value.th.lastName ?? "N/A"}'),

                      Text(
                          'Date of Birth (TH): ${controller.cardOriginal.value.th.dateOfBirth ?? "N/A"}'),
                      Text(
                          'Date of Issue (TH): ${controller.cardOriginal.value.th.dateOfIssue ?? "N/A"}'),
                      Text(
                          'Date of Expiry (TH): ${controller.cardOriginal.value.th.dateOfExpiry ?? "N/A"}'),
                      Text(
                          'Religion (TH): ${controller.cardOriginal.value.th.religion ?? "N/A"}'),
                      Text(
                          'Address (TH): ${controller.cardOriginal.value.th.address.full ?? "N/A"}'),
                      const Divider(),
                      Text(
                          'Full Name (EN): ${controller.cardOriginal.value.en.fullName ?? "N/A"}'),
                      Text(
                          'Prefix (EN): ${controller.cardOriginal.value.en.prefix ?? "N/A"}'),
                      Text(
                          'Name (EN): ${controller.cardOriginal.value.en.name ?? "N/A"}'),
                      Text(
                          'Last Name (EN): ${controller.cardOriginal.value.en.lastName ?? "N/A"}'),
                      Text(
                          'Date of Birth (EN): ${controller.cardOriginal.value.en.dateOfBirth ?? "N/A"}'),
                      Text(
                          'Date of Issue (EN): ${controller.cardOriginal.value.en.dateOfIssue ?? "N/A"}'),
                      Text(
                          'Date of Expiry (EN): ${controller.cardOriginal.value.en.dateOfExpiry ?? "N/A"}'),
                      Text(
                          'Religion (EN): ${controller.cardOriginal.value.en.religion ?? "N/A"}'),
                      Text(
                          'Address (EN): ${controller.cardOriginal.value.en.address.full ?? "N/A"}'),
                    ],
                  )
                else
                  const Text(
                    'No image captured yet.',
                    style: TextStyle(fontSize: 16),
                  ),
              if (controller.receivedData['typeofCard'] == '2')
                // show laser card original image and processed image
                // image
                Text(
                  'Image Path: ${controller.receivedData['processedFile'] ?? "Not available"}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              Text('SNR: ${controller.receivedData['snr'] ?? "N/A"}'),
              Text(
                  'Brightness: ${controller.receivedData['brightness'] ?? "N/A"}'),
              Text(
                  'Resolution: ${controller.receivedData['resolution'] ?? "N/A"}'),
              const SizedBox(height: 10),
              Text(
                  'Laser Code Original: ${controller.laserCodeOriginal.value}'),
              // show image
              if (controller.receivedData.isNotEmpty)

                // Check for valid file path before displaying the image
                if (controller.receivedData['processedFile'] != null &&
                    File(controller.receivedData['processedFile']).existsSync())
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.file(
                      File(controller.receivedData['processedFile']),
                      fit: BoxFit.cover,
                      width: 300,
                      height: 300,
                    ),
                  )
                else
                  const Text(
                    'Image file not found.',
                    style: TextStyle(fontSize: 16),
                  ),
              Divider(),
              Text('Laser Code: ${controller.laserCode.value}'),
              // show processed image
              if (controller.receivedData.isNotEmpty)

                // Check for valid file path before displaying the image
                if (controller.receivedData['processedFile'] != null &&
                    File(controller.receivedData['processedFile']).existsSync())
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.file(
                      File(controller.receivedData['processedFile']),
                      fit: BoxFit.cover,
                      width: 300,
                      height: 300,
                    ),
                  )
                else
                  const Text(
                    'Image file not found.',
                    style: TextStyle(fontSize: 16),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
