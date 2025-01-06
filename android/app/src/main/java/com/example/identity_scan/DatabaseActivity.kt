package com.example.identity_scan

import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.os.Bundle
import android.util.Log
import androidx.activity.compose.setContent
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.Role.Companion.Button
import androidx.compose.ui.unit.dp

class DatabaseActivity : AppCompatActivity() {

    private val dbHelper = DatabaseHelper(this)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        try {
            val db = dbHelper.writableDatabase

            val createTableQuery = """
            CREATE TABLE IF NOT EXISTS images (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                image_data TEXT NOT NULL
            )
        """.trimIndent()

            db.execSQL(createTableQuery)
        } catch (e: Exception) {
            e.printStackTrace()
            // คุณสามารถใช้ Log.e หรือ Log.d เพื่อลงข้อมูลใน log แทน
            Log.e("DatabaseError", "Error while creating table: ${e.message}")
        }

        setContent {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    Box(
                        contentAlignment = Alignment.Center,
                        modifier = Modifier.fillMaxSize()
                    ) {
                        Text(
                            text = "Hello, World!",
                            style = MaterialTheme.typography.bodyLarge,
                            modifier = Modifier.align(Alignment.TopCenter) // Align the text at the top center
                        )

                        // Button to insert mock data, placed below the Text
                        Button(
                            onClick = {
                                insertMockData()
                            },
                            modifier = Modifier.align(Alignment.Center) // Place button in the center
                        ) {
                            Text("Insert Mock Data")
                        }

                        // Button to select data, placed below the first button
                        Button(
                            onClick = {
                                selectData()
                            },
                            modifier = Modifier.align(Alignment.BottomCenter) // Place this button at the bottom center
                        ) {
                            Text("Select Data")
                        }

                    }
                }
        }
    }

    private fun insertMockData() {
        try {
            val db = dbHelper.writableDatabase
            val insertQuery = "INSERT INTO images (image_data) VALUES ('Mock Image Data 1')"
            db.execSQL(insertQuery)
            Log.d("Database", "Mock data inserted successfully.")
        } catch (e: Exception) {
            e.printStackTrace()
            Log.e("DatabaseError", "Error while inserting data: ${e.message}")
        }
    }

    private fun selectData() {
        try {
            val db = dbHelper.readableDatabase
            val selectQuery = "SELECT * FROM images"
            val cursor = db.rawQuery(selectQuery, null)

            val dbPath = db.path // This gives the absolute path of the database file
            println("DatabasePath Database Path: $dbPath")


            if (cursor != null && cursor.moveToFirst()) {
                do {
                    val idColumnIndex = cursor.getColumnIndex("id")
                    val imageDataColumnIndex = cursor.getColumnIndex("image_data")

                    // ตรวจสอบว่าคอลัมน์ที่เราต้องการมีอยู่จริง
                    if (idColumnIndex != -1 && imageDataColumnIndex != -1) {
                        val id = cursor.getInt(idColumnIndex)
                        val imageData = cursor.getString(imageDataColumnIndex)
                        println("ID: $id, Image Data: $imageData")
                        Log.d("Database", "ID: $id, Image Data: $imageData")
                    } else {
                        Log.e("DatabaseError", "Column index not found!")
                    }
                } while (cursor.moveToNext())
            } else {
                Log.d("Database", "No data found.")
            }
            cursor?.close()
        } catch (e: Exception) {
            e.printStackTrace()
            Log.e("DatabaseError", "Error while selecting data: ${e.message}")
        }
    }

}


class DatabaseHelper(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    companion object {
        private const val DATABASE_NAME = "identity_scan_db"
        private const val DATABASE_VERSION = 1
    }

    override fun onCreate(db: SQLiteDatabase) {
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {

    }
    
}
