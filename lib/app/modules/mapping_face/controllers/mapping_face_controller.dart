import 'dart:convert';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:identity_scan/app/data/models/card_type.dart';
import 'package:identity_scan/app/modules/flow_detact/controllers/flow_detact_controller.dart';

class MappingFaceController extends GetxController {
  //TODO: Implement MappingFaceController
  final flowDetectController = Get.find<FlowDetactController>();
  final similarity = 0.0.obs;

  final card = Rx<ID_CARD>(ID_CARD(
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
    laserCode: '',
  ));
  // laserCodeOriginal
  final laserCodeOriginal = ''.obs;
  // base64 image
  final imageFromCameraBase64 = ''.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  getDecodedPortrait() {
    try {
      Uint8List decodedImage = base64Decode(imageFromCameraBase64.value);
      print("Decoded portrait successfully");
      return decodedImage;
    } catch (e) {
      print("Invalid Base64 string for portrait: $e");
    }
  }
}
