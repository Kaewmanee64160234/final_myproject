import 'package:flutter/material.dart';

class LoadingView extends StatefulWidget {
  const LoadingView({super.key});

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: CircularProgressIndicator()),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              "โปรดรอ กำลังทำการดึงข้อมูลจากบัตร",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
