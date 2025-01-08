import 'dart:ui';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:identity_scan/model/image.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // final directory = await getApplicationDocumentsDirectory();
    // final dbPath = '${directory.path}/databases/identity_scan_db';

    // Database Path ที่ตรงกับ Kotlin Side
    final dbPath =
        '/data/user/0/com.example.identity_scan/databases/identity_scan_db';

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        // Create the table if it doesn't exist
        await db.execute("""
          CREATE TABLE IF NOT EXISTS images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            image_data TEXT NOT NULL
          )
        """);
      },
    );
    return _database!;
  }

  Future<ImageData> selectData() async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = '${directory.path}/databases/identity_scan_db';

    print(dbPath);
    final db = await database;
    // Perform a raw SQL query to select all rows from the images table

    final List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT * FROM images WHERE id = 1');

    ImageData image  = ImageData.fromMap(result[0]);
    print(image.imageData.length);
    return image;
  }
}
