import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:identity_scan/app/data/models/card_type.dart';
import 'package:identity_scan/app/data/models/receive_data.dart';
import 'package:identity_scan/app/data/models/services/api_ocr_credit_card_service.dart';
import 'package:identity_scan/app/routes/app_pages.dart';

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
  var laserCodeOriginal = ''.obs;
  var isLoading = false.obs;
  var similarity = 0.0.obs;
  var isApiActive = false.obs;
  final imageFromCameraBase64 = "".obs;

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
    }
  }

// openScanFace
  void openScanFace() async {
    try {
      final result = await platform.invokeMethod('openScanFace');
      print("Result from OpenCV: $result");
    } catch (e) {
      print("Error opening OpenCV view: $e");
      Get.snackbar("Error", "Failed to open OpenCV view.");
    }
  }

  Future<void> listenOnCameraResult() async {
    try {
      platform.setMethodCallHandler((call) async {
        print("Received method call from flutter ${call.method}");
        if (call.method == "onCameraResult") {
          print("Received camera result: ${call.arguments}");
          final receivedArguments = call.arguments;
          print("receivedArguments: $receivedArguments");
          if (receivedArguments != null) {
            sendToOcr(receivedArguments);
          }
        }
        if (call.method == "onCameraResultBack") {
          print("Received camera result back: ${call.arguments}");
          final receivedArguments = call.arguments;
          if (receivedArguments != null) {
            sendToOcrBackCard(receivedArguments);
          }
        }
        if (call.method == "onCameraScan") {
          print("Received camera result back: ${call.arguments}");
          final receivedArguments = call.arguments;
          if (receivedArguments != null) {
            // chnage path to find and convert to base64
            final bytes = await File(receivedArguments).readAsBytes();
            final imageBase64 = base64Encode(bytes);
            imageFromCameraBase64.value = imageBase64;
            print(imageBase64);
            compareSimilarity(imageBase64);
          }
        }
        if (call.method == "cancelApi") {
          print("cancelApi");
          clearDataForNewOCR();
          isApiActive.value = false;
        } else {
          print("Unhandled method call: ${call.method}");
        }
      });
    } catch (e) {
      print("Error listening for preprocessing result: $e");
      statusMessage.value = "Error listening for preprocessing result.";
    }
  }

  // clear data api
  void clearDataForNewOCR() {
    card.value = ID_CARD(
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
    );
    laserCodeOriginal.value = '';
    similarity.value = 0.0;
    isLoading.value = false;
  }

  // clearDataForNewOCR

  Future<void> sendToOcr(String path) async {
    try {
      if (!isApiActive.value) return;

      isLoading.value = true;

      if (path != null) {
        final File processedImage = File(path);
        print("isApiActive: $isApiActive.value");

        print("processedImage: $processedImage");

        if (await processedImage.exists()) {
          final bytes = await processedImage.readAsBytes();
          final imageBase64 = base64Encode(bytes);
          print("isApiActive: $isApiActive.value");
          if (!isApiActive.value) return;
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
      isLoading.value = false;
    } catch (e) {
      Get.snackbar("Error", "Failed to send processed image to OCR: $e");
      print("Error: Failed to send processed image to OCR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendToOcrBackCard(String path) async {
    try {
      print("isApiActive: $isApiActive.value");

      if (!isApiActive.value) return;

      isLoading.value = true; // Set loading state to true

      if (path != null) {
        final File processedImage = File(path);

        if (await processedImage.exists()) {
          final bytes = await processedImage.readAsBytes();
          final processedImageBase64 = base64Encode(bytes);

          final res = await apiOcrCreditCardService
              .uploadBase64ImageBack(processedImageBase64);
          print("OCR Processed Image Success: $res");
          print("isApiActive: $isApiActive.value");

          if (!isApiActive.value) return;

          card.value.laserCode = res;
          laserCodeOriginal.value = res;

          Get.snackbar("Success", "OCR for processed image completed.");
        } else {
          print("Error: Processed image file does not exist.");
          Get.snackbar("Error", "Processed image file not found.");
        }
      } else {
        Get.snackbar("Error", "No processed image path received.");
        print("Error: No processed image path received.");
      }
      isLoading.value = false; // Reset loading state
    } catch (e) {
      Get.snackbar("Error", "Failed to send processed image to OCR: $e");
      print("Error: Failed to send processed image to OCR: $e");
    } finally {
      isLoading.value = false; // Reset loading state
    }
  }

// compare misilality
  void compareSimilarity(String base64Image) async {
    try {
      isLoading.value = true;
      final res = await apiOcrCreditCardService.mappingFace(
          card.value.portrait, base64Image);
      print("Similarity: $res");
      similarity.value = res;
    } catch (e) {
      Get.snackbar("Error", "Failed to compare similarity: $e");
      print("Error: Failed to compare similarity: $e");
    } finally {
      isLoading.value = false;
      Get.toNamed(Routes.MAPPING_FACE);
    }
  }

  // imageFromCameraBase64 as Uint8List
  getDecodedPortrait() {
    return base64Decode(imageFromCameraBase64.value);
  }
}
