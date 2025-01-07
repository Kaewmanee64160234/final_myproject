import 'dart:convert';
import 'package:http/http.dart' as http;

class Api {
  final String baseUrl;

  Api(this.baseUrl);

 
  Future<http.Response?> post(String endpoint, Map<String, dynamic> formData, {String? authToken}) async {
    try {
      // Create MultipartRequest for sending form data
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'))
        ..headers.addAll({
          'Authorization':  '66eb9f21-8e1c-8011-97a5-08ddd9b9a7c7', // Add your auth token here
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
          request.files.add(http.MultipartFile.fromBytes(key, value, filename: key));
        }
      });

      // Send the request
      var response = await request.send();

      // Check response status
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print('Upload successful: $responseBody');
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
}

