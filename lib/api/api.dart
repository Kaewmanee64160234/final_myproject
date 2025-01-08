import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:identity_scan/model/front/id_card.dart';

class Api {
  static final String baseUrl = 'https://events.controldata.co.th/cardocr/';
  static String endpointFront = 'api/v1/upload_front_base64';

  void showErrorSnackbar({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      titleText: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      messageText: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  
  void showSuccessSnackbar({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      titleText: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      messageText: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Future<ID_CARD?> sendOcrFront(String fileData) async {
    try {
      Map<String, dynamic> formData = {
        'filedata': fileData,
      };

      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl$endpointFront'))
            ..headers.addAll({
              'Authorization': '66eb9f21-8e1c-8011-97a5-08ddd9b9a7c7',
            });

      // Add fields to the multipart request
      formData.forEach((key, value) {
        if (value is String) {
          request.fields[key] = value; // Add string fields
        } else if (value is List<int>) {
          request.files
              .add(http.MultipartFile.fromBytes(key, value, filename: key));
        }
      });

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();

        var jsonResponse = jsonDecode(responseBody);

        ID_CARD id_card = ID_CARD.fromJson(jsonResponse);
        print(jsonResponse);
        showSuccessSnackbar(title: "Success",message: "Get SUccess");
        return id_card;
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Error: ${response.statusCode}, $responseBody');
        return null;
      }
    } catch (e) {
      showErrorSnackbar(title: "Error", message: e.toString());
      print('There was an error: $e');
      return null;
    }
  }
}
