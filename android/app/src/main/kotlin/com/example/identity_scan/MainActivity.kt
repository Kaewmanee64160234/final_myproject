package com.example.identity_scan

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "native_function"
    private val REQUEST_CODE_SCAN = 1001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "getNativeMessage" -> {
                    val message = getNativeMessage()
                    result.success(message)
                    println(message)
                } "goToCamera" -> {
                    openCameraPage()
                } "openAnimationView" -> {
                    openAnimationView()
                } "openCaptureView" -> {
                    openCaptureView()
                } "openDbView" -> {
                    openDbView()
                }"openCvView" -> {
                    openOpenCVView()
                }

                
                else -> {
                    result.notImplemented()
                }
            }
        }

    }

    private fun getNativeMessage(): String {
        return "Hello from Native Android!"
    }

    private fun openCameraPage() {
        val intent = Intent(this@MainActivity, ScanFrontActivity::class.java)
        startActivityForResult(intent, REQUEST_CODE_SCAN)

//        startActivity(intent)
    }

    private fun openAnimationView() {
        val intent = Intent(this@MainActivity, AnimaActivity::class.java)
        startActivityForResult(intent, 1)
//        startActivity(intent)
    }

    private fun openCaptureView() {
        val intent = Intent(this@MainActivity, CaptureActivity::class.java)
        startActivity(intent)
    }

    private fun openDbView() {
        val intent = Intent(this@MainActivity, DatabaseActivity::class.java)
        startActivity(intent)
    }

    private fun openOpenCVView() {
        val intent = Intent(this@MainActivity, OpenCVActivity::class.java)
        startActivityForResult(intent, 2)

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 1 && resultCode == RESULT_OK) {
            // ได้รับผลลัพธ์จาก AnimaActivity
            val result = data?.getStringExtra("key") // รับค่าที่ส่งกลับจาก AnimaActivity
            // ใช้ผลลัพธ์ที่ได้ที่นี่
            println(result)
        }   else if (requestCode == 2 && resultCode == RESULT_OK) {
            // Get the processed file path
            val processedFilePath = data?.getStringExtra("processedFile")

            if (!processedFilePath.isNullOrEmpty()) {
                println("Processed file path received: $processedFilePath")

                try {
                    // Send the processed file path back to Flutter
                    MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "native_function")
                        .invokeMethod("onPreProcessingResult", processedFilePath)

                    println("Processed file path sent to Flutter: $processedFilePath")
                } catch (e: Exception) {
                    println("Error sending processed file path to Flutter: ${e.message}")
                }
            } else {
                println("Processed file path is null or empty.")
            }
        }else if (requestCode == REQUEST_CODE_SCAN){
            val result = data?.getStringExtra("result") // รับค่าที่ส่งกลับจาก ScanFronActivity
            println("Result From ScanFront Activity")
            println(result)

            try {
                // Send the result back to Flutter using the MethodChannel
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "native_function").invokeMethod("onCameraResult", result)
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "native_function").invokeMethod("onPreProcessingResult", result)
                // Print success status if method invocation is successful
                println("Result sent to Flutter successfully: $result")
            } catch (e: Exception) {
                // Print error status if there was an exception during the method invocation
                println("Error sending result to Flutter: ${e.message}")
            }

        }
    }
}
