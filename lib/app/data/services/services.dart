import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:identity_scan/app/data/models/card_type.dart';

class ApiOcrCreditCardService {
  final String _baseUrl = dotenv.env['PATH_API_OCR']!;
  final String _apiKey = dotenv.env['HEADER_API_OCR']!;
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
      final Uri uri = Uri.parse('$_baseUrl/api/v1/upload_front_base64');
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
            portrait: '');
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
          portrait: '');
    }
  }
}
