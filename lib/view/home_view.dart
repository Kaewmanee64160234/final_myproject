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
  String receivedData = "No data received yet";

  @override
  void initState() {
    super.initState();

    platform.setMethodCallHandler((call) async {
      if (call.method == "receiveDataFromKotlin") {
        setState(() {
          receivedData = call.arguments;
        });
        print("Received");
        print(receivedData.toString());
      }
    });
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
          // ElevatedButton(
          //     onPressed: (() {
          //       openCaptureScreen();
          //     }),
          //     child: Text("ShowImage")),
          ElevatedButton(
              onPressed: (() {
                openCaptureScreen();
              }),
              child: Text("CaptureView")),
          ElevatedButton(
              onPressed: (() {
                openDbScreen();
              }),
              child: Text("DatabaseView"))
        ],
      ),
    );
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

  static Future<String> openCaptureScreen() async {
    try {
      print("Opening");
      final String message = await platform.invokeMethod('openCaptureView');
      return message;
    } catch (e) {
      return "Failed to get native message: ${e.toString()}";
    }
  }

  static Future<String> openDbScreen() async {
    try {
      print("Opening");
      final String message = await platform.invokeMethod('openDbView');
      return message;
    } catch (e) {
      return "Failed to get native message: ${e.toString()}";
    }
  }
}
