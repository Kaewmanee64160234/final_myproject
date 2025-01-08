
class ID_CARD {
  final String idNumber;
  final ID_CARD_DETAIL th;
  final ID_CARD_DETAIL en;
  final String portrait;

  ID_CARD({
    required this.idNumber,
    required this.th,
    required this.en,
    required this.portrait,
  });

  factory ID_CARD.fromJson(Map<String, dynamic> json) {
    return ID_CARD(
      idNumber: json['idNumber'] ?? '',
      th: ID_CARD_DETAIL.fromJson(json['th']),
      en: ID_CARD_DETAIL.fromJson(json['en']),
      portrait: json['portrait'] ?? '',
    );
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

  factory ID_CARD_DETAIL.fromJson(Map<String, dynamic> json) {
    return ID_CARD_DETAIL(
      fullName: json['fullName'] ?? '',
      prefix: json['prefix'] ?? '',
      name: json['name'] ?? '',
      lastName: json['lastName'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      dateOfIssue: json['dateOfIssue'] ?? '',
      dateOfExpiry: json['dateOfExpiry'] ?? '',
      religion: json['religion'] ?? '',
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : Address.empty(),
    );
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

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      full: json['full'] ?? '',
      firstPart: json['firstPart'] ?? '',
      subdistrict: json['subdistrict'] ?? '',
      district: json['district'] ?? '',
      province: json['province'] ?? '',
    );
  }
  // toJson
  Map<String, dynamic> toJson() {
    return {
      'full': full,
      'firstPart': firstPart,
      'subdistrict': subdistrict,
      'district': district,
      'province': province,
    };
  }

  static empty() {
    return Address(
      full: '',
      firstPart: '',
      subdistrict: '',
      district: '',
      province: '',
    );
  }
}
