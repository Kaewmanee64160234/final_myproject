import 'package:get/get.dart';
import 'package:identity_scan/app/modules/flow_detact/controllers/flow_detact_controller.dart';

class OcrResultController extends GetxController {
  //TODO: Implement OcrResultController

  final count = 0.obs;
  final flowDetectController = Get.find<FlowDetactController>();
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

  void increment() => count.value++;
}
