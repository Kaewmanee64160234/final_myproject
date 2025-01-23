import 'dart:typed_data';

class Similarity {
  late Uint8List portraitImage;
  late Uint8List cameraImage;
  late double similarity;

  Similarity({required this.portraitImage,required this.cameraImage,required this.similarity});
}
