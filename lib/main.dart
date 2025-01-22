import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'package:google_fonts/google_fonts.dart';  


Future<void> main() async {
  await dotenv.load(fileName: ".env");
           
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        // กำหนดฟอนต์ให้กับ TextTheme ของแอป
      fontFamily: GoogleFonts.kanit().fontFamily
      ),
    ),
  );
}
