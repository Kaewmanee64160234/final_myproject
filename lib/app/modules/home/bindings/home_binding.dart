import 'package:get/get.dart';
import 'package:identity_scan/app/data/models/services/api_ocr_credit_card_service.dart';
import 'package:identity_scan/app/modules/mapping_face/controllers/mapping_face_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApiOcrCreditCardService());
    Get.put(HomeController());
  }
}
