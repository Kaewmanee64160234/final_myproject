import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const platform = MethodChannel('native_function');

  static const cameraMethod = MethodChannel('camera');

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
              child: Text("Animation"))
        ],
      ),
    );
  }

  Future<void> _onMethodCall(MethodCall call) async {
    if (call.method == "sendCapturedImage") {
      // Extract the byte data from the method call arguments
      final byteArray = call.arguments as Uint8List;

      // Update the image data in the state
      setState(() {
        var imageData = byteArray;
        print(imageData);
      });
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
