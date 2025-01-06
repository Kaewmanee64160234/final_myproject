package com.example.identity_scan

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "native_function"

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
                }"openOpenCVView" -> {
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
        startActivity(intent)
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
        startActivity(intent)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 1 && resultCode == RESULT_OK) {
            // ได้รับผลลัพธ์จาก AnimaActivity
            val result = data?.getStringExtra("key") // รับค่าที่ส่งกลับจาก AnimaActivity
            // ใช้ผลลัพธ์ที่ได้ที่นี่
            println(result)
        }else if (requestCode == 2 && resultCode == RESULT_OK) {
            // ได้รับผลลัพธ์จาก AnimaActivity
            val result = data?.getStringExtra("key") // รับค่าที่ส่งกลับจาก AnimaActivity
            // ใช้ผลลัพธ์ที่ได้ที่นี่
            println(result)
        }
    }
}
