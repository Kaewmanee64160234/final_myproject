import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:identity_scan/app/data/models/card_type.dart';

class ApiOcrCreditCardService {
  final String _baseUrl = dotenv.env['PATH_API_OCR']!;
  final _baseUrl2 = dotenv.env['PATH_MAPPING']!;
  final String _apiKey = dotenv.env['HEADER_API_OCR']!;
  final String _apiKey2 = dotenv.env['HEADER_API_OCR2']!;
  late Map<String, String> _header;

  ApiOcrCreditCardService() {
    _header = {
      'Authorization': _apiKey, // Add API key here
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json; charset=utf-8'
    };
  }

  // create api /api/v1/upload_front_file to send file image file *string($binary)
  Future<ID_CARD> uploadFile(File file) async {
    try {
      print('link: $_baseUrl/api/v1/upload_front_file');
      print('header: $_header');
      List<int> fileBytes = await file.readAsBytes();
      String base64File = base64Encode(fileBytes);
      final Map<String, String> payload = {
        'filedata': base64File,
      };
      print('payload: $payload');
      final Uri uri = Uri.parse('$_baseUrl/cardocr/api/v1/upload_front_base64');
      final response = await http.post(
        uri,
        headers: _header,
        body: payload,
      );
      print('response: ${response.body}');
      if (response.statusCode == 200) {
        final IdCard =
            ID_CARD.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        print('IdCard: $IdCard');
        return IdCard;
      } else {
        return ID_CARD(
            idNumber: '',
            th: ID_CARD_DETAIL(
              fullName: '',
              prefix: '',
              name: '',
              lastName: '',
              dateOfBirth: '',
              dateOfIssue: '',
              dateOfExpiry: '',
              religion: '',
              address: Address(
                province: '',
                district: '',
                full: '',
                firstPart: '',
                subdistrict: '',
              ),
            ),
            en: ID_CARD_DETAIL(
              fullName: '',
              prefix: '',
              name: '',
              lastName: '',
              dateOfBirth: '',
              dateOfIssue: '',
              dateOfExpiry: '',
              religion: '',
              address: Address(
                province: '',
                district: '',
                full: '',
                firstPart: '',
                subdistrict: '',
              ),
            ),
            portrait: '',
            laserCode: '');
      }
    } catch (e) {
      print('Error during file upload: $e');
      return ID_CARD(
          idNumber: '',
          th: ID_CARD_DETAIL(
            fullName: '',
            prefix: '',
            name: '',
            lastName: '',
            dateOfBirth: '',
            dateOfIssue: '',
            dateOfExpiry: '',
            religion: '',
            address: Address(
              province: '',
              district: '',
              full: '',
              firstPart: '',
              subdistrict: '',
            ),
          ),
          en: ID_CARD_DETAIL(
            fullName: '',
            prefix: '',
            name: '',
            lastName: '',
            dateOfBirth: '',
            dateOfIssue: '',
            dateOfExpiry: '',
            religion: '',
            address: Address(
              province: '',
              district: '',
              full: '',
              firstPart: '',
              subdistrict: '',
            ),
          ),
          portrait: '',
          laserCode: '');
    }
  }

  Future<ID_CARD> uploadBase64Image(String base64Image) async {
    try {
      Map<String, dynamic> formData = {
        'filedata': base64Image,
      };

      var request = http.MultipartRequest(
          'POST', Uri.parse('$_baseUrl/cardocr/api/v1/upload_front_base64'))
        ..headers.addAll({
          'Authorization': _apiKey,
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
      print('request: $request');
      var response = await request.send();
      print('response: $response');

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();

        var jsonResponse = jsonDecode(responseBody);

        ID_CARD id_card = ID_CARD.fromJson(jsonResponse);

        print(id_card.en.name);
        print(jsonResponse);
        return id_card;
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Error: ${response.statusCode}, $responseBody');
        return ID_CARD(
            idNumber: '',
            th: ID_CARD_DETAIL(
              fullName: '',
              prefix: '',
              name: '',
              lastName: '',
              dateOfBirth: '',
              dateOfIssue: '',
              dateOfExpiry: '',
              religion: '',
              address: Address(
                province: '',
                district: '',
                full: '',
                firstPart: '',
                subdistrict: '',
              ),
            ),
            en: ID_CARD_DETAIL(
              fullName: '',
              prefix: '',
              name: '',
              lastName: '',
              dateOfBirth: '',
              dateOfIssue: '',
              dateOfExpiry: '',
              religion: '',
              address: Address(
                province: '',
                district: '',
                full: '',
                firstPart: '',
                subdistrict: '',
              ),
            ),
            portrait: '',
            laserCode: '');
        ;
      }
    } catch (e) {
      print('There was an error: $e');
      return ID_CARD(
          idNumber: '',
          th: ID_CARD_DETAIL(
            fullName: '',
            prefix: '',
            name: '',
            lastName: '',
            dateOfBirth: '',
            dateOfIssue: '',
            dateOfExpiry: '',
            religion: '',
            address: Address(
              province: '',
              district: '',
              full: '',
              firstPart: '',
              subdistrict: '',
            ),
          ),
          en: ID_CARD_DETAIL(
            fullName: '',
            prefix: '',
            name: '',
            lastName: '',
            dateOfBirth: '',
            dateOfIssue: '',
            dateOfExpiry: '',
            religion: '',
            address: Address(
              province: '',
              district: '',
              full: '',
              firstPart: '',
              subdistrict: '',
            ),
          ),
          portrait: '',
          laserCode: '');
    }
  }

  // uploadBase64ImageBack input parameter and return as stringLaserCode
  Future<String> uploadBase64ImageBack(String base64Image) async {
    try {
      Map<String, dynamic> formData = {
        'filedata': base64Image,
      };

      var request = http.MultipartRequest(
          'POST', Uri.parse('$_baseUrl/cardocr/api/v1/upload_back_base64'))
        ..headers.addAll({
          'Authorization': _apiKey,
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

        String laserCode = jsonResponse['LaserCode'];

        print(laserCode);
        return laserCode;
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Error: ${response.statusCode}, $responseBody');
        return '';
      }
    } catch (e) {
      print('There was an error: $e');
      return '';
    }
  }

  Future<double> mappingFace(String base64Image1, String base64Image2) async {
    try {
      // Define the JSON payload
      Map<String, dynamic> jsonPayload = {
        'source_image': base64Image1, // Use source_image key
        'target_image': base64Image2, // Use target_image key
      };
      print("target_image $base64Image2");
      print("$_baseUrl2/api/v1/verification/verify");

      // Make a POST request
      var response = await http.post(
        Uri.parse('$_baseUrl2/api/v1/verification/verify'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey2,
        },
        body: jsonEncode(jsonPayload), // Encode the payload as JSON
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Extract similarity from the JSON response
        final similarity =
            jsonResponse['result']?[0]?['face_matches']?[0]?['similarity'];

        if (similarity != null) {
          print("Similarity: $similarity");
          return similarity.toDouble();
        } else {
          print("Similarity not found in response");
          return 0.0;
        }
      } else {
        print(response.body);

        print('Error: ${response.statusCode}, ${response.body}');
        return 0.0;
      }
    } catch (e) {
      print('There was an error: $e');
      return 0.0;
    }
  }
}
