package com.example.identity_scan

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.BasicText
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
import java.io.ByteArrayOutputStream

class CaptureActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
                CaptureScreen()

        }
    }
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
                        println(screenshotState.bitmapState.value.toString())

                        // Store the captured bitmap
                        screenshotState.bitmapState.value?.let { bitmap ->
                            capturedBitmap = bitmap // Store the captured bitmap
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


