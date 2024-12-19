import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const platform =
      MethodChannel('native_function');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: (() {
                getNativeMessage();
              }),
              child: Text("Call Print"))
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
}
