import 'package:get/get.dart';
import 'package:identity_scan/app/modules/flow_detact/controllers/flow_detact_controller.dart';

import '../controllers/ocr_result_controller.dart';

class OcrResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OcrResultController>(
      () => OcrResultController(),
    );
    Get.put(() => FlowDetactController());
  }
}
