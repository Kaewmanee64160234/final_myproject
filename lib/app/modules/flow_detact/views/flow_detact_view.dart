import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/flow_detact_controller.dart';

class FlowDetactView extends GetView<FlowDetactController> {
  const FlowDetactView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text(
              'ขั้นตอนการลงทะเบียน',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Color.fromRGBO(3, 6, 80, 1)),
        body: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'FlowDetactView is working',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),

          // add button at bottom long buttom for next step
          bottomNavigationBar: BottomAppBar(
            child: Container(
              decoration: BoxDecoration(),
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  controller.openCameraPage();
                },
                child: Text('เริ่มต้น'),
              ),
            ),
          ),
        ));
  }
}
