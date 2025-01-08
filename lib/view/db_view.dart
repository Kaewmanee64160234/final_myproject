import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:identity_scan/db/db_helper.dart';
import 'package:identity_scan/model/image.dart';
import 'package:identity_scan/view/image_view.dart';
import 'package:identity_scan/view/result/front_result_view.dart';

class DbView extends StatefulWidget {
  const DbView({super.key});

  @override
  State<DbView> createState() => _DbViewState();
}

class _DbViewState extends State<DbView> {
  late String base64Image;

  DatabaseHelper dbHelper = DatabaseHelper();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            onPressed: (() async {
              // ImageData image = await dbHelper.selectData();
              // setState(() {
              //   base64Image = image.imageData;
              // });
              try {
                // print(base64Image);
                // String cleanedBase64 = base64Image.replaceAll(RegExp(r'\s'), ''); // Remove all whitespaces

                // var imgMemory = base64Decode(cleanedBase64);
                Get.to(ImageView(
                  imagePath:
                      '/data/user/0/com.example.identity_scan/app_Images/image.jpg',
                ));
              } catch (e) {
                print("Error decoding Base64 string: $e");
                setState(() {
                  base64Image = ""; // Reset or display an error
                });
              }
            }),
            child: Text("Image View")),
        ElevatedButton(
            onPressed: (() async {
              try {
                Get.to(FrontResultView());
              } catch (e) {
                print(e);
              }
            }),
            child: Text("Result View"))
      ],
    ));
  }
}
