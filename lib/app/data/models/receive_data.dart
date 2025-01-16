// receipt data have 2 attribut type and image path
class ReceiveData {
  final String type;
  final String imagePath;

  ReceiveData({
    required this.type,
    required this.imagePath,
  });

  factory ReceiveData.fromJson(Map<String, dynamic> json) {
    return ReceiveData(
      type: json['type'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'imagePath': imagePath,
    };
  }
}
