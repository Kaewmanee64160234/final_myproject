import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class Api {
  final String baseUrl;

  Api(this.baseUrl);

  Future<void> post(String endpoint, Map<String, dynamic> formData) async {
    try {
      // Convert the form data to JSON format
      String jsonData = jsonEncode(formData);

      // Send a POST request
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonData,
      );

      // Handle the response
      if (response.statusCode == 200) {
        print('Upload successful: ${response.body}');
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('There was an error: $e');
    }
  }
}

// void main() async {
//   Api api = Api('https://events.controldata.co.th/cardocr/');
//   Map<String, dynamic> formData = {
//     'filedata': 'yourBase64EncodedFileString',  // Base64-encoded file
//   };

//   await api.post('upload_front_Base64', formData);
// }
