import 'package:get/get.dart';
import 'package:identity_scan/app/data/models/services/api_ocr_credit_card_service.dart';
import 'package:identity_scan/app/modules/mapping_face/controllers/mapping_face_controller.dart';

import '../controllers/flow_detact_controller.dart';

class FlowDetactBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FlowDetactController>(() => FlowDetactController(),
        fenix: true);
    Get.lazyPut<ApiOcrCreditCardService>(
      () => ApiOcrCreditCardService(),
    );
    Get.lazyPut<MappingFaceController>(
      () => MappingFaceController(),
    );
  }
}
