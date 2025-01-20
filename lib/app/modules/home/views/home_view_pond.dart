import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeViewPond extends StatefulWidget {
  HomeViewPond({super.key});

  @override
  State<HomeViewPond> createState() => _HomeViewPondState();
}

class _HomeViewPondState extends State<HomeViewPond> {
  static const platform = MethodChannel('native_function');
  static String pickImageOk = 'ok';

  late Uint8List imageDataList = Uint8List(0);
  String receivedData = "No data received yet";

  int facepluginState = -1;



  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler((call) async {
      if (call.method == "onCameraResult") {
        print("Received Data From native");
        setState(() {
          receivedData = call.arguments;
        });
        // print("Received");
        // print(receivedData.toString());

        // ถ้า Received Data = ok ให้ไปที่ หน้า Api และเริ่มการ OCR
        //   if(receivedData.toString() == pickImageOk){
        //     Get.to(LoadingView());
        //   }
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
                openAnimationView();
              }),
              child: Text("Animation")),
          ElevatedButton(
              onPressed: (() {
                openCaptureView();
              }),
              child: Text("CaptureView")),
          ElevatedButton(
              onPressed: (() {
                openOpenCVView();
              }),
              child: Text("OpenCV View")),
          ElevatedButton(
              onPressed: (() {
              }),
              child: Text("LivenessView"))
        ],
      ),
    );
  }

  static Future<String> openCamera() async {
    try {
      final String message = await platform.invokeMethod('goToCamera');
      return message;
    } catch (e) {
      return "Failed to get native message: ${e.toString()}";
    }
  }

  static Future<String> openAnimationView() async {
    try {
      final String message = await platform.invokeMethod('openAnimationView');
      return message;
    } catch (e) {
      return "Failed to get native message: ${e.toString()}";
    }
  }

  static Future<String> openCaptureView() async {
    try {
      print("Opening");
      final String message = await platform.invokeMethod('openCaptureView');
      return message;
    } catch (e) {
      return "Failed to get native message: ${e.toString()}";
    }
  }

  static Future<String> openOpenCVView() async {
    try {
      final String message = await platform.invokeMethod('openOpenCVView');
      return message;
    } catch (e) {
      return "Failed to get native message: ${e.toString()}";
    }
  }
}
