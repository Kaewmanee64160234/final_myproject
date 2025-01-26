import 'dart:convert';
import 'dart:typed_data';

class Similarity {
  late Uint8List portraitImage;
  late Uint8List cameraImage;
  late double similarity;

  Similarity({
    required this.portraitImage,
    required this.cameraImage,
    required this.similarity,
  });

  // Convert from JSON
  factory Similarity.fromJson(Map<String, dynamic> json) {
    // Decode base64 to Uint8List for portraitImage and cameraImage
    return Similarity(
      portraitImage: base64Decode(json['portraitImage']),
      cameraImage: base64Decode(json['cameraImage']),
      similarity: json['similarity'] ?? 0.0,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'portraitImage': base64Encode(portraitImage), // Convert to base64 string
      'cameraImage': base64Encode(cameraImage),   // Convert to base64 string
      'similarity': similarity,
    };
  }
}
