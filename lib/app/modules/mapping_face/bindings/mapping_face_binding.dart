import 'package:get/get.dart';

import '../controllers/mapping_face_controller.dart';

class MappingFaceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MappingFaceController>(
      () => MappingFaceController(),
    );
  }
}
