import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/result_ocr_controller.dart';

class ResultOcrView extends GetView<ResultOcrController> {
  const ResultOcrView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ResultOcrView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ResultOcrView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
