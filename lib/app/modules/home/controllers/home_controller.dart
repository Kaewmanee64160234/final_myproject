import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:identity_scan/app/data/models/card_type.dart';
import 'package:identity_scan/app/data/models/services/api_ocr_credit_card_service.dart';

class HomeController extends GetxController {
  static const platform = MethodChannel('native_function');

  var receivedData = <String, dynamic>{}.obs; // Observable for processed data
  var statusMessage = "Waiting for preprocessing...".obs; // Status message
  var isLoading = false.obs; // Loading state
  final processedImageBase64 = "".obs; // Base64-encoded processed image
  final originalImageBase64 = "".obs; // Base64-encoded original sharpened image
  final ApiOcrCreditCardService apiOcrCreditCardService = Get.find();

  final card = ID_CARD(
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
  ).obs;
  final cardOriginal = ID_CARD(
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
  ).obs;
  @override
  void onInit() {
    super.onInit();
    listenForPreprocessingResult(); // Start listening for native callbacks
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// Opens the OpenCV view using the native method
  void openOpenCVView() async {
    try {
      final result = await platform.invokeMethod('openCvView');
      print("Result from OpenCV: $result");
    } catch (e) {
      print("Error opening OpenCV view: $e");
      Get.snackbar("Error", "Failed to open OpenCV view.");
    }
  }

  Future<void> listenForPreprocessingResult() async {
    try {
      platform.setMethodCallHandler((call) async {
        if (call.method == "onPreProcessingResult") {
          final Map<dynamic, dynamic> receivedArguments = call.arguments;

          if (receivedArguments != null && receivedArguments.isNotEmpty) {
            print("Received Data from Native: $receivedArguments");

            // Extract values from the received arguments
            final processedFilePath = receivedArguments['processedFile'];
            final originalSharpenedPath =
                receivedArguments['originalSharpenedPath'];
            final brightness = receivedArguments['brightness'];
            final snr = receivedArguments['snr'];
            final resolution = receivedArguments['resolution'];

            // Update the observable `receivedData`
            receivedData.value = {
              'processedFile': processedFilePath,
              'originalSharpenedPath': originalSharpenedPath,
              'brightness': brightness,
              'snr': snr,
              'resolution': resolution,
            };

            print("Updated receivedData: $receivedData");

            // Optionally, trigger additional processing or UI updates
            statusMessage.value = "Image preprocessing completed.";
            await sendToOcr();
            await sendToOcrOriginal();
          } else {
            print("Error: Received incomplete data.");
            statusMessage.value = "Error: Received incomplete data.";
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

  Future<void> sendToOcr() async {
    try {
      isLoading.value = true; // Set loading state to true

      if (receivedData.value['processedFile'] != null) {
        final File processedImage = File(receivedData['processedFile']);

        if (await processedImage.exists()) {
          // Convert the file to Base64
          final bytes = await processedImage.readAsBytes();
          processedImageBase64.value = base64Encode(bytes);

          // Send the image to the OCR service
          card.value = (await apiOcrCreditCardService
              .uploadBase64Image(processedImageBase64.value))!;
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

  /// Sends the original sharpened image to the OCR service
  Future<void> sendToOcrOriginal() async {
    try {
      isLoading.value = true; // Set loading state to true

      if (receivedData.value['originalSharpenedPath'] != null) {
        final File originalSharpenedImage =
            File(receivedData['originalSharpenedPath']);

        if (await originalSharpenedImage.exists()) {
          // Convert the file to Base64
          final bytes = await originalSharpenedImage.readAsBytes();
          originalImageBase64.value = base64Encode(bytes);

          // Send the image to the OCR service
          cardOriginal.value = (await apiOcrCreditCardService
              .uploadBase64Image(originalImageBase64.value))!;
          print("OCR Original Sharpened Image Success: ${card.value.idNumber}");

          Get.snackbar(
              "Success", "OCR for original sharpened image completed.");
        } else {
          print("Error: Original sharpened image file does not exist.");
          Get.snackbar("Error", "Original sharpened image file not found.");
        }
      } else {
        Get.snackbar("Error", "No original sharpened image path received.");
        print("Error: No original sharpened image path received.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to send original image to OCR: $e");
      print("Error: Failed to send original image to OCR: $e");
    } finally {
      isLoading.value = false; // Reset loading state
    }
  }
}
