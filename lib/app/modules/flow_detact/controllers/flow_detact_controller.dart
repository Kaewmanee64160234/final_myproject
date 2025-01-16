import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:identity_scan/app/data/models/card_type.dart';
import 'package:identity_scan/app/data/models/receive_data.dart';
import 'package:identity_scan/app/data/models/services/api_ocr_credit_card_service.dart';

class FlowDetactController extends GetxController {
  final count = 0.obs;
  var card = ID_CARD(
    idNumber: '',
    th: ID_CARD_DETAIL(
      fullName: '',
      prefix: '',
      name: '',
      lastName: '',
      dateOfBirth: '',
      dateOfIssue: '',
      dateOfExpiry: '',
      religion: '',
      address: Address(
        province: '',
        district: '',
        full: '',
        firstPart: '',
        subdistrict: '',
      ),
    ),
    en: ID_CARD_DETAIL(
      fullName: '',
      prefix: '',
      name: '',
      lastName: '',
      dateOfBirth: '',
      dateOfIssue: '',
      dateOfExpiry: '',
      religion: '',
      address: Address(
        province: '',
        district: '',
        full: '',
        firstPart: '',
        subdistrict: '',
      ),
    ),
    portrait: '',
    laserCode: '',
  ).obs;
  final ApiOcrCreditCardService apiOcrCreditCardService = Get.find();
  static const platform = MethodChannel('native_function');
  var statusMessage = "Waiting for preprocessing...".obs;
  var isLoading = false.obs;
  var receivedData = ReceiveData(type: '', imagePath: '').obs;

  @override
  void onInit() {
    super.onInit();
    listenOnCameraResult();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void openCameraPage() async {
    try {
      final result = await platform.invokeMethod('goToCamera');
      print("Result from OpenCV: $result");
    } catch (e) {
      print("Error opening OpenCV view: $e");
      print(e);
      // Get.snackbar("Error", "Failed to open OpenCV view.");
    }
  }

  Future<void> listenOnCameraResult() async {
    try {
      platform.setMethodCallHandler((call) async {
        print("Received method call from flutter ${call.method}");
        if (call.method == "onCameraResult") {
          print("Received camera result: ${call.arguments}");
          //  output just string result
          final receivedArguments = call.arguments;
          // map to receipve data
          receivedData.value = ReceiveData.fromJson(receivedArguments);
          if (receivedData.value.type == 'font') {
            sendToOcr(receivedData.value.imagePath);
          }
          if (receivedData.value.type == 'back') {
            sendToOcr(receivedData.value.imagePath);
          }
        } else {
          print("Unhandled method call: ${call.method}");
        }
      });
    } catch (e) {
      print("Error listening for preprocessing result: $e");
      statusMessage.value = "Error listening for preprocessing result.";
    }
  }

  Future<void> sendToOcr(String path) async {
    try {
      isLoading.value = true; // Set loading state to true

      if (path != null) {
        final File processedImage = File(path);
        print("processedImage: $processedImage");

        if (await processedImage.exists()) {
          // Convert the file to Base64
          final bytes = await processedImage.readAsBytes();
          final imageBase64 = base64Encode(bytes);

          // Send the image to the OCR service
          card.value =
              (await apiOcrCreditCardService.uploadBase64Image(imageBase64))!;
          print("OCR Processed Image Success: ${card.value.idNumber}");

          Get.snackbar("Success", "OCR for processed image completed.");
        } else {
          print("Error: Processed image file does not exist.");
          Get.snackbar("Error", "Processed image file not found.");
        }
      } else {
        Get.snackbar("Error", "No processed image path received.");
        print("Error: No processed image path received.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to send processed image to OCR: $e");
      print("Error: Failed to send processed image to OCR: $e");
    } finally {
      isLoading.value = false; // Reset loading state
    }
  }

  Future<void> sendToOcrBackCard(String path) async {
    try {
      isLoading.value = true; // Set loading state to true

      if (path != null) {
        final File processedImage = File(path);
        // Convert the file to Base64

        if (await processedImage.exists()) {
          final bytes = await processedImage.readAsBytes();
          final processedImageBase64 = base64Encode(bytes);

          // Send the image to the OCR service
          final res = await apiOcrCreditCardService
              .uploadBase64ImageBack(processedImageBase64);
          print("OCR Processed Image Success: $res");
          card.value.laserCode = res;

          Get.snackbar("Success", "OCR for processed image completed.");
        } else {
          print("Error: Processed image file does not exist.");
          Get.snackbar("Error", "Processed image file not found.");
        }
      } else {
        Get.snackbar("Error", "No processed image path received.");
        print("Error: No processed image path received.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to send processed image to OCR: $e");
      print("Error: Failed to send processed image to OCR: $e");
    } finally {
      isLoading.value = false; // Reset loading state
    }
  }
}
