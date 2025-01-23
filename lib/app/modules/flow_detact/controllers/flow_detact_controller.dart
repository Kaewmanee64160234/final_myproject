import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:identity_scan/app/data/models/card_type.dart';
import 'package:identity_scan/app/data/models/services/api_ocr_credit_card_service.dart';
import 'package:identity_scan/app/data/models/services/similarity.dart';
import 'package:identity_scan/app/modules/mapping_face/controllers/mapping_face_controller.dart';
import 'package:identity_scan/app/routes/app_pages.dart';

import '../../mapping_face/views/mapping_face_view.dart';

class FlowDetactController extends GetxController {
  final count = 0.obs;

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
  // create valiable for edit data id card
  var idNumber = ''.obs;
  var fullName = ''.obs;
  var prefix = ''.obs;
  var firstName = ''.obs;
  var lastName = ''.obs;
  var dateOfBirth = ''.obs;
  var dateOfIssue = ''.obs;
  var dateOfExpiry = ''.obs;
  var religion = ''.obs;
  var address = ''.obs;
  var prefixEn = ''.obs;
  var firstNameEn = ''.obs;
  var lastNameEn = ''.obs;
  var dateOfBirthEn = ''.obs;
  var dateOfIssueEn = ''.obs;
  var dateOfExpiryEn = ''.obs;
  // error message for validate
  var idNumberError = ''.obs;
  var fullNameError = ''.obs;
  var prefixError = ''.obs;
  var firstNameError = ''.obs;
  var lastNameError = ''.obs;
  var dateOfBirthError = ''.obs;
  var dateOfIssueError = ''.obs;
  var dateOfExpiryError = ''.obs;
  var religionError = ''.obs;
  var addressError = ''.obs;
  var prefixEnError = ''.obs;
  var firstNameEnError = ''.obs;
  var lastNameEnError = ''.obs;
  var dateOfBirthEnError = ''.obs;
  var dateOfIssueEnError = ''.obs;
  var dateOfExpiryEnError = ''.obs;
  var laserCodeError = ''.obs;

  final ApiOcrCreditCardService apiOcrCreditCardService = Get.put(ApiOcrCreditCardService());
  static const platform = MethodChannel('native_function');
  var statusMessage = "Waiting for preprocessing...".obs;
  var laserCodeOriginal = ''.obs;
  var isLoading = false.obs;
  var similarity = 0.0.obs;
  var isApiActive = false.obs;
  final imageFromCameraBase64 = "".obs;
  // isValid
  var isValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    listenOnCameraResult();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void openCameraPage() async {
    try {
      final result = await platform.invokeMethod('goToCamera');
      print("Result from OpenCV: $result");
    } catch (e) {
      print("Error opening OpenCV view: $e");
      print(e);
    }
  }

// openScanFace
  void openScanFace() async {
    try {
      final result = await platform.invokeMethod('openScanFace');
      print("Result from OpenCV: $result");
    } catch (e) {
      print("Error opening OpenCV view: $e");
    }
  }

  Future<void> listenOnCameraResult() async {
    try {
      platform.setMethodCallHandler((call) async {
        print("Received method call from flutter ${call.method}");
        if (call.method == "onCameraResult") {
          print("Received camera result: ${call.arguments}");
          final receivedArguments = call.arguments;
          print("receivedArguments: $receivedArguments");
          if (receivedArguments != null) {
            sendToOcr(receivedArguments);
          }
        }
        if (call.method == "onCameraResultBack") {
          print("Received camera result back: ${call.arguments}");
          final receivedArguments = call.arguments;
          if (receivedArguments != null) {
            sendToOcrBackCard(receivedArguments);
          }
        }
        if (call.method == "onCameraScan") {
          print("Received camera result back: ${call.arguments}");
          final receivedArguments = call.arguments;
          if (receivedArguments != null) {
            // chnage path to find and convert to base64
            final bytes = await File(receivedArguments).readAsBytes();
            final imageBase64 = base64Encode(bytes);
            imageFromCameraBase64.value = imageBase64;
            print(imageBase64);
            compareSimilarity(imageBase64);
          }
        }
        if (call.method == "cancelApi") {
          print("cancelApi");
          clearDataForNewOCR();
          isApiActive.value = false;
        } else {
          print("Unhandled method call: ${call.method}");
        }
      });
    } catch (e) {
      print("Error listening for preprocessing result: $e");
      statusMessage.value = "Error listening for preprocessing result.";
    }
  }

  // clear data api
  void clearDataForNewOCR() {
    card.value = ID_CARD(
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
    );
    laserCodeOriginal.value = '';
    idNumber.value = '';
    fullName.value = '';
    prefix.value = '';
    firstName.value = '';
    lastName.value = '';
    dateOfBirth.value = '';
    dateOfIssue.value = '';
    dateOfExpiry.value = '';
    religion.value = '';
    address.value = '';
    prefixEn.value = '';
    firstNameEn.value = '';
    lastNameEn.value = '';
    dateOfBirthEn.value = '';
    dateOfIssueEn.value = '';
    dateOfExpiryEn.value = '';
    imageFromCameraBase64.value = "";

    similarity.value = 0.0;
    isLoading.value = false;
  }

  // clearDataForNewOCR

  Future<void> sendToOcr(String path) async {
    try {
      if (!isApiActive.value) return;

      isLoading.value = true;

      if (path != null) {
        final File processedImage = File(path);
        print("isApiActive: $isApiActive.value");

        print("processedImage: $processedImage");

        if (await processedImage.exists()) {
          final bytes = await processedImage.readAsBytes();
          final imageBase64 = base64Encode(bytes);
          print("isApiActive: $isApiActive.value");
          if (!isApiActive.value) return;
          card.value =
              (await apiOcrCreditCardService.uploadBase64Image(imageBase64))!;
          print("OCR Processed Image Success: ${card.value.idNumber}");
          // set data
          idNumber.value = card.value.idNumber;
          fullName.value = card.value.th.fullName;
          prefix.value = card.value.th.prefix;
          firstName.value = card.value.th.name;

          lastName.value = card.value.th.lastName;
          dateOfBirth.value = card.value.th.dateOfBirth;
          dateOfIssue.value = card.value.th.dateOfIssue;
          dateOfExpiry.value = card.value.th.dateOfExpiry;
          religion.value = card.value.th.religion;
          address.value = card.value.th.address.full;
          prefixEn.value = card.value.en.prefix;
          firstNameEn.value = card.value.en.name;
          lastNameEn.value = card.value.en.lastName;
          dateOfBirthEn.value = card.value.en.dateOfBirth;
          dateOfIssueEn.value = card.value.en.dateOfIssue;
          dateOfExpiryEn.value = card.value.en.dateOfExpiry;
        } else {
          print("Error: Processed image file does not exist.");
        }
      } else {
        print("Error: No processed image path received.");
      }
      isLoading.value = false;
    } catch (e) {
      print("Error: Failed to send processed image to OCR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendToOcrBackCard(String path) async {
    try {
      print("isApiActive: $isApiActive.value");

      if (!isApiActive.value) return;

      isLoading.value = true; // Set loading state to true

      if (path != null) {
        final File processedImage = File(path);

        if (await processedImage.exists()) {
          final bytes = await processedImage.readAsBytes();
          final processedImageBase64 = base64Encode(bytes);

          final res = await apiOcrCreditCardService
              .uploadBase64ImageBack(processedImageBase64);

          print("OCR Processed Image Success: $res");
          print("isApiActive: $isApiActive.value");

          if (!isApiActive.value) return;

          card.value.laserCode = res;
          laserCodeOriginal.value = res;
          isApiActive.value = false;
          // set data
          laserCodeOriginal.value = card.value.laserCode;
        } else {
          print("Error: Processed image file does not exist.");
        }
      } else {
        print("Error: No processed image path received.");
      }
      isLoading.value = false; // Reset loading state
    } catch (e) {
      print("Error: Failed to send processed image to OCR: $e");
    } finally {
      isLoading.value = false; // Reset loading state
    }
  }

  void compareSimilarity(String base64Image) async {
    try {
      isLoading.value = true;

      // Validate Base64 string before making API call
      try {
        base64Decode(card.value.portrait);
        base64Decode(base64Image);
      } catch (e) {
        throw Exception("Invalid Base64 image data");
      }

      final res = await apiOcrCreditCardService.mappingFace(
        card.value.portrait,
        base64Image,
      );

      print("Similarity: $res");
      similarity.value = res;
    } catch (e) {
      print("Error: Failed to compare similarity: $e");
    } finally {
      isLoading.value = false;

      final mappingFaceController = Get.find<MappingFaceController>();
      mappingFaceController.similarity.value = similarity.value;
      mappingFaceController.card.value = card.value;
      mappingFaceController.laserCodeOriginal.value = laserCodeOriginal.value;
      mappingFaceController.imageFromCameraBase64.value =
          imageFromCameraBase64.value;
      print("data: ${mappingFaceController.card.value.idNumber}");
      print("data: ${mappingFaceController.laserCodeOriginal.value}");
      print("data: ${mappingFaceController.imageFromCameraBase64.value}");

      Similarity similarityObject = Similarity(
          portraitImage: base64Decode(card.value.portrait),
          cameraImage: base64Decode(imageFromCameraBase64.value),
          similarity: similarity.value);
      ID_CARD cardObject = createCardObject();

      // Navigate to the next page without back navigation
      Get.offAll(MappingFaceView(
        card: cardObject, // ส่งค่าของ cardObject
        similarity: similarityObject, // ส่งค่าของ similarityObject
      )); 
      
      // Get.offAndToNamed(
      //   Routes.MAPPING_FACE,
      //   arguments: {
      //     'portraitImage': base64Decode(card.value.portrait),
      //     'cameraImage': base64Decode(base64Image),
      //     'similarity': similarity.value,
      //   },
      // );
    }
  }

  // imageFromCameraBase64 as Uint8List
  getDecodedPortrait() {
    return base64Decode(imageFromCameraBase64.value);
  }
  
  bool validateIdCard(String idNumber) {
    // Check length and if it's numeric
    if (idNumber.length != 13 || int.tryParse(idNumber) == null) {
      return false;
    }

    // Convert to list of digits
    List<int> digits = idNumber.split('').map(int.parse).toList();

    // Split into main digits and check digit
    List<int> mainDigits = digits.sublist(0, 12);
    int checkDigit = digits[12];

    // Calculate the total sum
    int total = 0;
    for (int i = 0; i < mainDigits.length; i++) {
      total += mainDigits[i] * (13 - i);
    }

    // Calculate remainder and expected check digit
    int remainder = total % 11;
    int calculatedCheckDigit = (11 - remainder) % 10;

    // Compare calculated check digit with the actual check digit
    return calculatedCheckDigit == checkDigit;
  }

  String? validateField(String value, {required String fieldName}) {
    if (value.isEmpty) return '$fieldName is required';
    if (fieldName == 'Card ID' && value.length < 13) {
      return 'Card ID must be at least 13 characters';
    }
    if (fieldName == 'Date of Birth' &&
        !RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
      return 'Date of Birth must be in DD/MM/YYYY format';
    }
    return null; // No errors
  }

  void validateFields() {
    // clear error message
    idNumberError.value = '';
    fullNameError.value = '';
    prefixError.value = '';
    firstNameError.value = '';
    lastNameError.value = '';
    dateOfBirthError.value = '';
    dateOfIssueError.value = '';
    dateOfExpiryError.value = '';
    religionError.value = '';
    addressError.value = '';
    prefixEnError.value = '';
    firstNameEnError.value = '';
    lastNameEnError.value = '';
    dateOfBirthEnError.value = '';
    dateOfIssueEnError.value = '';
    dateOfExpiryEnError.value = '';
    laserCodeError.value = '';

    // validate
    if (idNumber.value.isEmpty) {
      idNumberError.value = 'ต้องระบุเลขบัตรประชาชน';
      // alert show card id is required
      Get.snackbar('ต้องระบุเลขบัตรประชาชน', 'กรุณากรอกเลขบัตรประชาชน');
    }
    if (validateIdCard(idNumber.value) == false) {
      idNumberError.value = 'เลขบัตรประชาชนไม่ถูกต้อง';
      Get.snackbar(
          'เลขบัตรประชาชนไม่ถูกต้อง', 'กรุณากรอกเลขบัตรประชาชนที่ถูกต้อง');
    }
    if (fullName.value.isEmpty) {
      fullNameError.value = 'ต้องระบุชื่อเต็ม';
      Get.snackbar('ต้องระบุชื่อเต็ม', 'กรุณากรอกชื่อเต็ม');
    }
    if (prefix.value.isEmpty) {
      prefixError.value = 'ต้องระบุคำนำหน้า';
      Get.snackbar('ต้องระบุคำนำหน้า', 'กรุณากรอกคำนำหน้า');
    }
    if (firstName.value.isEmpty) {
      firstNameError.value = 'ต้องระบุชื่อ';
      Get.snackbar('ต้องระบุชื่อ', 'กรุณากรอกชื่อ');
    }
    if (lastName.value.isEmpty) {
      lastNameError.value = 'ต้องระบุนามสกุล';
      Get.snackbar('ต้องระบุนามสกุล', 'กรุณากรอกนามสกุล');
    }
    if (dateOfBirth.value.isEmpty) {
      dateOfBirthError.value = 'ต้องระบุวันเดือนปีเกิด';
      Get.snackbar('ต้องระบุวันเดือนปีเกิด', 'กรุณากรอกวันเดือนปีเกิด');
    }
    if (dateOfIssue.value.isEmpty) {
      dateOfIssueError.value = 'ต้องระบุวันที่ออกบัตร';
      Get.snackbar('ต้องระบุวันที่ออกบัตร', 'กรุณากรอกวันที่ออกบัตร');
    }
    if (dateOfExpiry.value.isEmpty) {
      dateOfExpiryError.value = 'ต้องระบุวันหมดอายุ';
      Get.snackbar('ต้องระบุวันหมดอายุ', 'กรุณากรอกวันหมดอายุ');
    }
    if (religion.value.isEmpty) {
      religionError.value = 'ต้องระบุศาสนา';
      Get.snackbar('ต้องระบุศาสนา', 'กรุณากรอกศาสนา');
    }
    if (address.value.isEmpty) {
      addressError.value = 'ต้องระบุที่อยู่';
      Get.snackbar('ต้องระบุที่อยู่', 'กรุณากรอกที่อยู่');
    }
    if (prefixEn.value.isEmpty) {
      prefixEnError.value = 'ต้องระบุคำนำหน้าภาษาอังกฤษ';
      Get.snackbar('ต้องระบุคำนำหน้าภาษาอังกฤษ', 'กรุณากรอกคำนำหน้าภาษาอังกฤษ');
    }
    if (firstNameEn.value.isEmpty) {
      firstNameEnError.value = 'ต้องระบุชื่อภาษาอังกฤษ';
      Get.snackbar('ต้องระบุชื่อภาษาอังกฤษ', 'กรุณากรอกชื่อภาษาอังกฤษ');
    }
    if (lastNameEn.value.isEmpty) {
      lastNameEnError.value = 'ต้องระบุนามสกุลภาษาอังกฤษ';
      Get.snackbar('ต้องระบุนามสกุลภาษาอังกฤษ', 'กรุณากรอกนามสกุลภาษาอังกฤษ');
    }
    if (dateOfBirthEn.value.isEmpty) {
      dateOfBirthEnError.value = 'ต้องระบุวันเดือนปีเกิดภาษาอังกฤษ';
      Get.snackbar('ต้องระบุวันเดือนปีเกิดภาษาอังกฤษ',
          'กรุณากรอกวันเดือนปีเกิดภาษาอังกฤษ');
    }
    if (dateOfIssueEn.value.isEmpty) {
      dateOfIssueEnError.value = 'ต้องระบุวันที่ออกบัตรภาษาอังกฤษ';
      Get.snackbar('ต้องระบุวันที่ออกบัตรภาษาอังกฤษ',
          'กรุณากรอกวันที่ออกบัตรภาษาอังกฤษ');
    }
    if (dateOfExpiryEn.value.isEmpty) {
      dateOfExpiryEnError.value = 'ต้องระบุวันหมดอายุภาษาอังกฤษ';
      Get.snackbar(
          'ต้องระบุวันหมดอายุภาษาอังกฤษ', 'กรุณากรอกวันหมดอายุภาษาอังกฤษ');
    }
    if (laserCodeOriginal.value.isEmpty) {
      laserCodeError.value = 'ต้องระบุเลเซอร์โค้ด';
      Get.snackbar('ต้องระบุเลเซอร์โค้ด', 'กรุณากรอกเลเซอร์โค้ด');
    }

    if (idNumberError.value.isEmpty &&
        fullNameError.value.isEmpty &&
        prefixError.value.isEmpty &&
        firstNameError.value.isEmpty &&
        lastNameError.value.isEmpty &&
        dateOfBirthError.value.isEmpty &&
        dateOfIssueError.value.isEmpty &&
        dateOfExpiryError.value.isEmpty &&
        religionError.value.isEmpty &&
        addressError.value.isEmpty &&
        prefixEnError.value.isEmpty &&
        firstNameEnError.value.isEmpty &&
        lastNameEnError.value.isEmpty &&
        dateOfBirthEnError.value.isEmpty &&
        dateOfIssueEnError.value.isEmpty &&
        dateOfExpiryEnError.value.isEmpty &&
        laserCodeError.value.isEmpty) {
      isValid.value = true;
    } else {
      isValid.value = false;
    }
  }

  ID_CARD createCardObject() {
    // สร้าง object ใหม่จากค่าที่เก็บใน Rx
    ID_CARD newIdCard = ID_CARD(
      idNumber: idNumber.value, // ดึงค่าจาก Rx idNumber
      th: ID_CARD_DETAIL(
        fullName: fullName.value,
        prefix: prefix.value,
        name: firstName.value,
        lastName: lastName.value,
        dateOfBirth: dateOfBirth.value,
        dateOfIssue: dateOfIssue.value,
        dateOfExpiry: dateOfExpiry.value,
        religion: religion.value,
        address: Address(
          province: address.value,
          district: '', // ปรับค่าตามที่คุณต้องการ
          full: '', // ปรับค่าตามที่คุณต้องการ
          firstPart: '', // ปรับค่าตามที่คุณต้องการ
          subdistrict: '', // ปรับค่าตามที่คุณต้องการ
        ),
      ),
      en: ID_CARD_DETAIL(
        fullName: "none",
        prefix: prefixEn.value,
        name: firstNameEn.value,
        lastName: lastNameEn.value,
        dateOfBirth: dateOfBirthEn.value,
        dateOfIssue: dateOfIssueEn.value,
        dateOfExpiry: dateOfExpiryEn.value,
        religion: religion.value,
        address: Address(
          province: address.value, // กรณีนี้สามารถใช้ address ที่เดียวกัน
          district: '', // ปรับค่าตามที่คุณต้องการ
          full: '',
          firstPart: '',
          subdistrict: '',
        ),
      ),
      portrait: imageFromCameraBase64.value, // กำหนดค่า portrait
      laserCode: laserCodeOriginal.value, // ดึงค่าจาก laserCode
    );

    // สามารถใช้งาน `newIdCard` ต่อไปตามที่ต้องการ
    print(newIdCard.toString());
    print(newIdCard.th.name);

    return newIdCard;
  }
}
