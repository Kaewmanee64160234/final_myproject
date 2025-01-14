import 'package:get/get.dart';
import 'package:identity_scan/app/data/models/services/api_ocr_credit_card_service.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApiOcrCreditCardService());
    Get.put(HomeController());
  }
}
