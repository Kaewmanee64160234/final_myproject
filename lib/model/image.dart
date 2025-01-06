class ImageData {
  late int id;
  late String imageData;

  ImageData({required this.id, required this.imageData});

  ImageData.fromMap(Map<String, dynamic> map) {
    id = map['id'] as int;
    imageData = map['image_data'] as String;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageData': imageData,
    };
  }
}
