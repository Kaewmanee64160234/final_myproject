import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/routes/app_pages.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // ใช้สำหรับโหลดข้อมูล locale

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th_TH', null); 
  Intl.defaultLocale = 'th_TH'; 
  await dotenv.load(fileName: ".env");
  await GetStorage.init(); // เริ่มต้นการใช้งาน GetStorage
  
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // กำหนดฟอนต์ให้กับ TextTheme ของแอป
          fontFamily: GoogleFonts.kanit().fontFamily),
    ),
  );
}
