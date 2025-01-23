import 'package:get/get.dart';
import 'package:identity_scan/app/modules/flow_detact/controllers/flow_detact_controller.dart';
import 'package:identity_scan/app/modules/mapping_face/controllers/mapping_face_controller.dart';

import '../controllers/result_ocr_controller.dart';

class ResultOcrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FlowDetactController());
    Get.lazyPut(() => ResultOcrController());
  }
}
