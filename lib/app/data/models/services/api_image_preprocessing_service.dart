import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

class ApiImagePreprocessingService {
  ApiImagePreprocessingService();
  final String _baseUrl = dotenv.env['PATH_API_IMAGE']!;
  // header
  final Map<String, String> _header = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${dotenv.env['HEADER_API_OCR']}'
  };

  Future<String> preprocessImage(String imagePath) async {
    try {
      print("Preprocessing image: $imagePath");
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception("File not found: $imagePath");
      }

      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      final Map<String, dynamic> payload = {"image_base64": base64Image};

      final Uri uri = Uri.parse("$_baseUrl/api/v1/process_image");
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String? processedImageBase64 =
            responseData['processed_image_base64'];
        print(responseData);

        if (processedImageBase64 != null) {
          print(
              "Processed image received: ${processedImageBase64.length} bytes");
          // Decode Base64 string
          final processedBytes = base64Decode(processedImageBase64);

          // Get the external storage directory
          final Directory? externalDir = await getExternalStorageDirectory();
          if (externalDir == null) {
            throw Exception("External storage directory is not available.");
          }
          print("External Directory: ${externalDir.path}");

          // Define the result path
          final String resultPath = '${externalDir.path}/processed_image.jpg';

          // Save the processed image
          final File processedImageFile = File(resultPath);
          await processedImageFile.writeAsBytes(processedBytes);

          // print("Processed image saved at: $resultPath");
          return processedImageBase64;
        } else {
          throw Exception("Processed image not found in response");
        }
      } else {
        throw Exception(
            "Failed to preprocess image: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Error in preprocessImage: $e");
      return '';
    }
  }

  // send to read ocr
  Future<void> uploadFile(File file, String type) async {
    try {
      List<int> fileBytes = await file.readAsBytes();
      String base64File = base64Encode(fileBytes);

      Map<String, dynamic> payload = {'file': base64File, 'type': type};

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/upload_front_file'),
        headers: _header,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('File uploaded successfully: ${response.body}');
      } else {
        print(
            'Failed to upload file: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error during file upload: $e');
    }
  }
}
