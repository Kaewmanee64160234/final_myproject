import 'dart:convert';
import 'dart:typed_data';

class ID_CARD {
  final String idNumber;
  final ID_CARD_DETAIL th;
  final ID_CARD_DETAIL en;
  final String portrait;
  String laserCode;

  ID_CARD({
    required this.idNumber,
    required this.th,
    required this.en,
    required this.portrait,
    required this.laserCode,
  });

  // Factory method to create an instance from JSON
  factory ID_CARD.fromJson(Map<String, dynamic> json) {
    return ID_CARD(
      idNumber: json['idNumber'] ?? '',
      th: ID_CARD_DETAIL.fromJson(json['th']),
      en: ID_CARD_DETAIL.fromJson(json['en']),
      portrait: json['portrait'] ?? '',
      laserCode: json['LaserCode'] ?? '',
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'idNumber': idNumber,
      'th': th.toJson(),
      'en': en.toJson(),
      'portrait': portrait,
      'LaserCode': laserCode,
    };
  }

  // Decode Base64 portrait string to Uint8List
  Uint8List getDecodedPortrait() {
    return base64Decode(portrait);
  }
}

class ID_CARD_DETAIL {
  final String fullName;
  final String prefix;
  final String name;
  final String lastName;
  final String dateOfBirth;
  final String dateOfIssue;
  final String dateOfExpiry;
  final String religion;
  final Address address;

  ID_CARD_DETAIL({
    required this.fullName,
    required this.prefix,
    required this.name,
    required this.lastName,
    required this.dateOfBirth,
    required this.dateOfIssue,
    required this.dateOfExpiry,
    required this.religion,
    required this.address,
  });

  // Factory method to create an instance from JSON
  factory ID_CARD_DETAIL.fromJson(Map<String, dynamic> json) {
    String validateDate(String date) {
      if (date == 'th_data' || date == 'en_data') {
        return '';
      }
      return date;
    }

    return ID_CARD_DETAIL(
      fullName: json['fullName'] ?? '',
      prefix: json['prefix'] ?? '',
      name: json['name'] ?? '',
      lastName: json['lastName'] ?? '',
      dateOfBirth: validateDate(json['dateOfBirth'] ?? ''),
      dateOfIssue: validateDate(json['dateOfIssue'] ?? ''),
      dateOfExpiry: validateDate(json['dateOfExpiry'] ?? ''),
      religion: json['religion'] ?? '',
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : Address.empty(),
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'prefix': prefix,
      'name': name,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'dateOfIssue': dateOfIssue,
      'dateOfExpiry': dateOfExpiry,
      'religion': religion,
      'address': address.toJson(),
    };
  }
}

class Address {
  final String full;
  final String firstPart;
  final String subdistrict;
  final String district;
  final String province;

  Address({
    required this.full,
    required this.firstPart,
    required this.subdistrict,
    required this.district,
    required this.province,
  });

  // Factory method to create an instance from JSON
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      full: json['full'] ?? '',
      firstPart: json['firstPart'] ?? '',
      subdistrict: json['subdistrict'] ?? '',
      district: json['district'] ?? '',
      province: json['province'] ?? '',
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'full': full,
      'firstPart': firstPart,
      'subdistrict': subdistrict,
      'district': district,
      'province': province,
    };
  }

  // Create an empty address instance
  static Address empty() {
    return Address(
      full: '',
      firstPart: '',
      subdistrict: '',
      district: '',
      province: '',
    );
  }
}
