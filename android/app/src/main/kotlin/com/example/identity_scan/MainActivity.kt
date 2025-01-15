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
                }"openScanFace" ->{
                openScanFace()
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
    private fun openScanFace() {
        val intent = Intent(this@MainActivity, ScanFace::class.java)
        startActivity(intent)

    }
    private fun openScanFont() {
        val intent = Intent(this@MainActivity, ScanFrontActivity::class.java)
        startActivity(intent)

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == 1 && resultCode == RESULT_OK) {
            val result = data?.getStringExtra("key")
            println("Result from AnimaActivity: $result")
        } else if (requestCode == 2 && resultCode == RESULT_OK) {
            val processedFilePath = data?.getStringExtra("processedFile")
            val originalSharpenedPath = data?.getStringExtra("originalSharpenedPath")
            val brightness = data?.getDoubleExtra("brightness", -1.0)
            val snr = data?.getDoubleExtra("snr", -1.0)
            val resolution = data?.getStringExtra("resolution")
            val typeofCard = data?.getStringExtra("typeofCard")


            if (processedFilePath != null && originalSharpenedPath != null) {
                println("Processed file: $processedFilePath")
                println("Sharpened file: $originalSharpenedPath")
                println("Brightness: $brightness, SNR: $snr, Resolution: $resolution")
                println("typeofCard: $typeofCard");
                try {
                    // Prepare the map to send back to Flutter
                    val resultData = mapOf(
                        "processedFile" to processedFilePath,
                        "originalSharpenedPath" to originalSharpenedPath,
                        "brightness" to brightness,
                        "snr" to snr,
                        "resolution" to resolution,
                        "typeofCard" to typeofCard
                    )

                    // Send data to Flutter
                    MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "native_function")
                        .invokeMethod("onPreProcessingResult", resultData)

                    println("Data sent to Flutter: $resultData")
                } catch (e: Exception) {
                    println("Error sending data to Flutter: ${e.message}")
                }
            } else {
                println("Error: Missing data in the result intent.")
            }
        } else if (requestCode == REQUEST_CODE_SCAN) {
            val result = data?.getStringExtra("result")
            println("Result From ScanFront Activity: $result")

            try {
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "native_function")
                    .invokeMethod("onCameraResult", result)
                println("Camera result sent to Flutter successfully: $result")
            } catch (e: Exception) {
                println("Error sending camera result to Flutter: ${e.message}")
            }
        }
    }

}
