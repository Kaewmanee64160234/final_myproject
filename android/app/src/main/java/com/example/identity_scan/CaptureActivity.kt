package com.example.identity_scan

import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.smarttoolfactory.screenshot.ScreenshotBox
import com.smarttoolfactory.screenshot.rememberScreenshotState
import android.graphics.Bitmap
import android.util.Base64
import androidx.compose.foundation.Image
import androidx.compose.foundation.border
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

class CaptureActivity : AppCompatActivity() {

    private val CHANNEL = "native_function"
    lateinit var flutterEngine: FlutterEngine

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        flutterEngine = FlutterEngine(this)

        // ตรงนี้สำคัญ เพื่อที่จะให้ Method ทำงานได้ ต้องมีตรงนี้
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        MethodChannel(flutterEngine.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendDataToFlutter") {
                val dataToSend = "Hello from Kotlin!"
                result.success(dataToSend)
            } else {
                result.notImplemented()
            }
        }

        setContent {
                CaptureScreen()

        }
    }


    private fun sendDataToFlutter(message : String) {
        // Access the MethodChannel to send data to Flutter
        MethodChannel(flutterEngine.dartExecutor, CHANNEL).invokeMethod("receiveDataFromKotlin", message)
    }


    @Composable
    fun CaptureScreen() {
        val screenshotState = rememberScreenshotState()

        // State to hold the captured bitmap
        var capturedBitmap by remember { mutableStateOf<Bitmap?>(null) }

        ScreenshotBox(screenshotState = screenshotState) {
            Scaffold { innerPadding ->
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(innerPadding),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center,
                        modifier = Modifier.padding(16.dp)
                    ) {
                        Text(
                            text = "Camera view will be here",
                            fontSize = 18.sp,
                            color = MaterialTheme.colorScheme.onBackground
                        )

                        Spacer(modifier = Modifier.height(16.dp))

                        // Display captured bitmap as an image
                        capturedBitmap?.let {
                            Image(
                                bitmap = it.asImageBitmap(),
                                contentDescription = "Captured Image",
                                modifier = Modifier
                                    .size(300.dp) // Adjust size as needed
                                    .border(2.dp, Color.Gray)                     )
                        }

                        Spacer(modifier = Modifier.height(16.dp))

                        // Button to capture the screenshot
                        Button(onClick = {

                            screenshotState.capture()
                            println("ScreenshotState")
//                            println(screenshotState.bitmapState.value.toString())

                            // Store the captured bitmap
                            screenshotState.bitmapState.value?.let { bitmap ->
                                capturedBitmap = bitmap
                                var messageSent = bitmapToBase64(bitmap)
                                sendDataToFlutter(messageSent)

                            } ?: run {
                                println("No screenshot captured")
                            }
                        }) {
                            Text(text = "Capture")
                        }
                    }
                }
            }
        }
    }

    fun bitmapToBase64(bitmap: Bitmap): String {
        val byteArrayOutputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
        val byteArray = byteArrayOutputStream.toByteArray()
        return Base64.encodeToString(byteArray, Base64.DEFAULT)
    }


}

