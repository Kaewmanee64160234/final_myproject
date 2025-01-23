import 'package:get/get.dart';

import '../modules/flow_detact/bindings/flow_detact_binding.dart';
import '../modules/flow_detact/views/flow_detact_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/mapping_face/bindings/mapping_face_binding.dart';
import '../modules/mapping_face/views/mapping_face_view.dart';
import '../modules/ocr_result/bindings/ocr_result_binding.dart';
import '../modules/ocr_result/views/ocr_result_view.dart';
import '../modules/result_ocr/bindings/result_ocr_binding.dart';
import '../modules/result_ocr/views/result_ocr_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.FLOW_DETACT,
      page: () => const FlowDetactView(),
      binding: FlowDetactBinding(),
    ),
    GetPage(
      name: _Paths.MAPPING_FACE,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return MappingFaceView(
          portraitImage: args['portraitImage'],
          cameraImage: args['cameraImage'],
          similarity: args['similarity'],
          card: args['card'],
        );
      },
      binding: MappingFaceBinding(),
    ),
    GetPage(
      name: _Paths.RESULT_OCR,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return ResultOcrView(
          card: args['card'],
        );
      },
      binding: ResultOcrBinding(),
    ),
    GetPage(
      name: _Paths.OCR_RESULT,
      page: () => OcrResultView(),
      binding: OcrResultBinding(),
    ),
  ];
}
