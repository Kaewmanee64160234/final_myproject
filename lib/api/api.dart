import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:identity_scan/model/front/id_card.dart';

import '../model/front/front_th_data.dart';

class Api {
  final String baseUrl;

  Api(this.baseUrl);

  Future<http.Response?> post(String endpoint, Map<String, dynamic> formData,
      {String? authToken}) async {
    try {
      // Create MultipartRequest for sending form data
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'))
            ..headers.addAll({
              'Authorization':
                  '66eb9f21-8e1c-8011-97a5-08ddd9b9a7c7', // Add your auth token here
            });

      // Ensure 'filedata' is included in the formData and handle accordingly
      if (!formData.containsKey('filedata')) {
        print('Error: filedata field is required.');
        return null;
      }

      // Add fields to the multipart request (add text fields)
      formData.forEach((key, value) {
        if (value is String) {
          request.fields[key] = value; // Add string fields
        } else if (value is List<int>) {
          request.files
              .add(http.MultipartFile.fromBytes(key, value, filename: key));
        }
      });

      // Send the request
      var response = await request.send();

      // Check response status
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        // print('Upload successful: $responseBody');
        // Error ที่นี่

        return http.Response(responseBody, 200);
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Error: ${response.statusCode}, $responseBody');
        return http.Response(responseBody, response.statusCode);
      }
    } catch (e) {
      print('There was an error: $e');
    }
  }

  Future<ID_CARD?> sendOcrFront(String endpoint, String fileData) async {
    try {
      // Create a new formData map
      Map<String, dynamic> formData = {
        'filedata':
            fileData, // The file data is now added to the form data map with the 'filedata' key
      };

      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'))
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

      // Send the request
      var response = await request.send();

      // Check response status
      if (response.statusCode == 200) {
        // Convert the response body to a String
        final responseBody = await response.stream.bytesToString();

        // Parse the responseBody as JSON
        var jsonResponse = jsonDecode(responseBody);

        // Create and return the ID_CARD object from the JSON response
        ID_CARD id_card = ID_CARD.fromJson(jsonResponse);
        return id_card; // Return the ID_CARD object
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Error: ${response.statusCode}, $responseBody');
        return null; // Return null in case of an error
      }
    } catch (e) {
      print('There was an error: $e');
      return null; // Return null in case of an exception
    }
  }
}
