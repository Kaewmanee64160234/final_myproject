import 'package:get/get.dart';

import '../controllers/result_ocr_controller.dart';

class ResultOcrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResultOcrController>(
      () => ResultOcrController(),
    );
  }
}
