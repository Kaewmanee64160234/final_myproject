import 'package:get/get.dart';
import 'package:identity_scan/app/modules/flow_detact/controllers/flow_detact_controller.dart';

import '../controllers/mapping_face_controller.dart';

class MappingFaceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MappingFaceController>(
      () => MappingFaceController(),
    );
    Get.lazyPut<FlowDetactController>(
      () => FlowDetactController(),
    );
  }
}
