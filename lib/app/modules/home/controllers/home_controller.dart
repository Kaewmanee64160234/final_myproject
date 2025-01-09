import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:identity_scan/app/data/models/card_type.dart';
import 'package:identity_scan/app/data/services/services.dart';
import 'package:identity_scan/app/modules/home/views/home_view.dart';

class HomeController extends GetxController {
  static const platform = MethodChannel('native_function');

  var receivedData = "".obs;
  var statusMessage = "Waiting for preprocessing...".obs;
  var isLoading = false.obs;
  final RxString processedImageBase64 = RxString('');
  final ApiOcrCreditCardService apiOcrCreditCardService = Get.find();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final Rx<ID_CARD> card = ID_CARD(
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
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  static Future<String> openOpenCVView() async {
    try {
      final String message = await platform.invokeMethod('openCvView');
      return message;
    } catch (e) {
      return "Failed to get native message: ${e.toString()}";
    }
  }

  Future<void> listenForPreprocessingResult() async {
    try {
      platform.setMethodCallHandler((call) async {
        if (call.method == "onPreProcessingResult") {
          // Update the received data
          receivedData.value = call.arguments;
          print("Processed image path received: ${receivedData.value}");

          // Update status message and handle navigation
          if (receivedData.value.isNotEmpty) {
            statusMessage.value =
                "Image preprocessing completed. Redirecting...";
            isLoading.value = true;

            // Navigate to a new screen or show the image
            Get.offAll(() => HomeView());
          } else {
            statusMessage.value = "Error: Received empty path.";
          }
        }
      });
    } on PlatformException catch (e) {
      statusMessage.value =
          "Error listening for preprocessing result: ${e.message}";
    }
  }

// about api
// create functio nchnage image file to base64
  Future<void> changeImageToBase64() async {
    try {
      isLoading.value = true; // Show loading spinner

      // Check if the selected image is available
      if (selectedImage.value != null) {
        // Read the image file as bytes
        final bytes = await selectedImage.value!.readAsBytes();

        // Encode the bytes to Base64 string
        final base64Image = base64Encode(bytes);
        processedImageBase64.value = base64Image;

        // Log the successful result
        print('Image converted to Base64: $base64Image');
      } else {
        Get.snackbar("Error", "No image selected.");
      }
    } catch (e) {
      // Handle and log errors
      Get.snackbar("Error", "Failed to convert image to Base64: $e");
      print("Error in changeImageToBase64: $e");
    } finally {
      // Hide loading spinner regardless of success or error
      isLoading.value = false;
    }
  }

  Future<void> sendToOcr() async {
    try {
      isLoading.value = true; // Show loading spinner

      // Check if the processed Base64 image is available
      if (processedImageBase64.value.isNotEmpty) {
        // Decode Base64 string into bytes
        final processedBytes = base64Decode(processedImageBase64.value);

        // Create a temporary file to store the processed image
        final Directory tempDir = Directory.systemTemp;
        final File processedImage = File('${tempDir.path}/processed_image.jpg');
        await processedImage.writeAsBytes(processedBytes);

        // Send the file to the OCR API
        final card_ = await apiOcrCreditCardService.uploadFile(processedImage);
        card.value = card_;

        // Log the successful result
        print('Card details: ${card.value.idNumber}');
      } else {
        Get.snackbar("Error", "No processed image found.");
      }
    } catch (e) {
      // Handle and log errors
      Get.snackbar("Error", "Failed to send image to OCR: $e");
      print("Error in sendToOcr: $e");
    } finally {
      // Hide loading spinner regardless of success or error
      isLoading.value = false;
    }
  }
}
