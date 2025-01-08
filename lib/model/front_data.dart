import 'dart:convert';

class FrontData {
  final String idNumber;
  final String fullName;
  final String prefix;
  final String name;
  final String lastName;
  final String dateOfBirth;
  final String dateOfIssue;
  final String dateOfExpiry;
  final String religion;
  final Address address;
  final String portrait;

  FrontData({
    required this.idNumber,
    required this.fullName,
    required this.prefix,
    required this.name,
    required this.lastName,
    required this.dateOfBirth,
    required this.dateOfIssue,
    required this.dateOfExpiry,
    required this.religion,
    required this.address,
    required this.portrait,
  });

  // Create an instance of FrontData from a JSON map
  factory FrontData.fromJson(Map<String, dynamic> json) {
    return FrontData(
      idNumber: json['idNumber'],
      fullName: json['th']['fullName'],
      prefix: json['th']['prefix'],
      name: json['th']['name'],
      lastName: json['th']['lastName'],
      dateOfBirth: json['th']['dateOfBirth'],
      dateOfIssue: json['th']['dateOfIssue'],
      dateOfExpiry: json['th']['dateOfExpiry'],
      religion: json['th']['religion'],
      address: Address.fromJson(json['th']['address']), // Address is mapped from JSON
      portrait: json['portrait'], // The portrait image (base64 string or path)
    );
  }

  // Convert FrontData to JSON map
  Map<String, dynamic> toJson() {
    return {
      'idNumber': idNumber,
      'th': {
        'fullName': fullName,
        'prefix': prefix,
        'name': name,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'dateOfIssue': dateOfIssue,
        'dateOfExpiry': dateOfExpiry,
        'religion': religion,
        'address': address.toJson(),
      },
      'portrait': portrait,
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

  // Create an instance of Address from a JSON map
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      full: json['full'],
      firstPart: json['firstPart'],
      subdistrict: json['subdistrict'],
      district: json['district'],
      province: json['province'],
    );
  }

  // Convert Address to JSON map
  Map<String, dynamic> toJson() {
    return {
      'full': full,
      'firstPart': firstPart,
      'subdistrict': subdistrict,
      'district': district,
      'province': province,
    };
  }
}
