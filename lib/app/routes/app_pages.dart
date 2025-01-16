import 'package:get/get.dart';

import '../modules/flow_detact/bindings/flow_detact_binding.dart';
import '../modules/flow_detact/views/flow_detact_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';

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
  ];
}
