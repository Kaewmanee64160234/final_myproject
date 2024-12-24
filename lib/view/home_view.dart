import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const platform = MethodChannel('native_function');
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
