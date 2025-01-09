import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:identity_scan/app/modules/home/views/home_view.dart';

class HomeController extends GetxController {
  // Define the MethodChannel
  static const platform = MethodChannel('native_function');

  // Rx variables for dynamic status updates
  var receivedData = "".obs; // To store received data from native
  var statusMessage = "Waiting for preprocessing...".obs; // Status message
  var isLoading = false.obs; // Loading status to show progress indicators

  // Function to invoke native preprocessing
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
            Get.to(() => HomeView());
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

  final count = 0.obs;

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

  void increment() => count.value++;
}
