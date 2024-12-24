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
        startActivity(intent)
    }
}
