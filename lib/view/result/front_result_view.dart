import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:identity_scan/model/front/id_card.dart';

class FrontResultView extends StatefulWidget {
  final ID_CARD idCard;

  const FrontResultView({super.key, required this.idCard});

  @override
  State<FrontResultView> createState() => _FrontResultViewState();
}

class _FrontResultViewState extends State<FrontResultView> {
  static late String profilePicString;

  static Image decodeBase64ToImage(String base64String) {
    Uint8List bytes = base64Decode(base64String);
    // Return the image from the bytes
    return Image.memory(bytes);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      profilePicString = widget.idCard.portrait;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ผลการสแกนหน้าบัตร"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (profilePicString.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(
                  height: 200,
                  child: decodeBase64ToImage(profilePicString),
                ),
              ),
            Text(
              "รหัสประจำตัว: ${widget.idCard.idNumber}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller:
                  TextEditingController(text: widget.idCard.th.fullName),
              decoration: InputDecoration(
                labelText: "ชื่อ - สกุล",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(),
              ),
              readOnly: false,
            ),
            SizedBox(height: 16),
            TextField(
              controller:
                  TextEditingController(text: widget.idCard.th.address.full),
              decoration: InputDecoration(
                labelText: "Address",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(),
              ),
              readOnly: false,
            ),
          ],
        ),
      ),
    );
  }
}
