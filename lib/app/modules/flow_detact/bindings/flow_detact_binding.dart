import 'package:get/get.dart';
import 'package:identity_scan/app/data/models/services/api_ocr_credit_card_service.dart';

import '../controllers/flow_detact_controller.dart';

class FlowDetactBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FlowDetactController>(
      () => FlowDetactController(),
    );
    Get.lazyPut<ApiOcrCreditCardService>(
      () => ApiOcrCreditCardService(),
    );
  }
}
