import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:identity_scan/view/image_view.dart';

class HomeView extends StatefulWidget {
  HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const platform = MethodChannel('native_function');

  static const cameraMethod = MethodChannel('camera');
  // late Uint8List imageDataList;

  late Uint8List imageDataList = Uint8List(0); // Initialize with empty data

  @override
  void initState() {
    super.initState();

    // Listen for method calls from Android
    cameraMethod.setMethodCallHandler(_onMethodCall);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: (() {
                openCamera();
              }),
              child: Text("OpenCamera")),
          ElevatedButton(
              onPressed: (() {
                openAnimationScreen();
              }),
              child: Text("Animation")),
          ElevatedButton(
              onPressed: (() {
                Get.to(ImageView(imageBytes: imageDataList));
              }),
              child: Text("ShowImage"))
        ],
      ),
    );
  }

  Future<void> _onMethodCall(MethodCall call) async {
    if (call.method == "sendCapturedImage") {
      // Extract the byte data from the method call arguments
      final byteArray = call.arguments as Uint8List;

      // Update the image data in the state
      var imageData = null;
      setState(() {
        imageData = byteArray;
      });
      print("ImageData = $imageData");
      print("ImageData type = ${imageData.runtimeType}");

      try {
        if (imageData is! Uint8List) {
          print("Changing State");
          setState(() {
            imageDataList = Uint8List.fromList(imageData);
          });
        } else {
          setState(() {
            // this.imageDataList = imageData  ; //convert imageData
            imageDataList = Uint8List.fromList(imageData);
          });
          print("Convert Success");
          print("ImageData type = ${this.imageDataList.runtimeType}");
        }
      } catch (e, stackTrace) {
        print("Error during conversion: $e");
        print("StackTrace: $stackTrace");
      }
    }
  }

  static Future<String> getNativeMessage() async {
    try {
      final String message = await platform.invokeMethod('getNativeMessage');
      return message;
    } catch (e) {
      return "Failed to get native message: ${e.toString()}";
    }
  }

  static Future<String> openCamera() async {
    try {
      final String message = await platform.invokeMethod('goToCamera');
      return message;
    } catch (e) {
      return "Failed to get native message: ${e.toString()}";
    }
  }

  static Future<String> openAnimationScreen() async {
    try {
      final String message = await platform.invokeMethod('openAnimationView');
      return message;
    } catch (e) {
      return "Failed to get native message: ${e.toString()}";
    }
  }
}
