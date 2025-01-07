package com.example.identity_scan

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.util.Size
import androidx.activity.compose.setContent
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.core.resolutionselector.ResolutionStrategy
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import com.example.identity_scan.ml.ModelUnquant
import com.smarttoolfactory.screenshot.ScreenshotBox
import com.smarttoolfactory.screenshot.rememberScreenshotState
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class OpenCVActivity : AppCompatActivity() {
    private lateinit var cameraExecutor: ExecutorService
    private val CAMERA_REQUEST_CODE = 2001
    private lateinit var model: ModelUnquant
    private lateinit var flutterEngine: FlutterEngine
    private lateinit var methodChannel: MethodChannel
    private val CHANNEL = "camera"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        cameraExecutor = Executors.newSingleThreadExecutor()
        checkAndRequestCameraPermission()
        model = ModelUnquant.newInstance(this)

        // Initialize FlutterEngine manually
        flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        methodChannel = MethodChannel(flutterEngine.dartExecutor, CHANNEL)
//        install open cv
        if (!org.opencv.android.OpenCVLoader.initDebug()) {
            Log.e("OpenCV", "OpenCV initialization failed")
        } else {
            Log.d("OpenCV", "OpenCV initialization successful")
        }

        setContent {
            Surface(
                modifier = Modifier.fillMaxSize(),
                color = Color.Black // Explicitly set the background color to black
            ) {

                Column(modifier = Modifier.fillMaxSize()) {
                    // Title Row
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.Center
                    ) {
                        Text(
                            modifier = Modifier
                                .height(80.dp)
                                .padding(16.dp),
                            text = "OpenCV View",
                            color = Color.White,
                            style = TextStyle(fontSize = 20.sp, fontWeight = FontWeight.Bold)
                        )
                    }

                    // Camera Preview
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .fillMaxWidth()
                    ) {
                        CameraPreview()
                    }

                    // Exit Button Row
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        horizontalArrangement = Arrangement.Center
                    ) {
                        Button(onClick = { finish() }) {
                            Text("Exit")
                        }
                    }
                }
            }
        }

    }

    @Composable
    fun CameraPreview(modifier: Modifier = Modifier) {
        val screenshotState = rememberScreenshotState()
        val context = LocalContext.current
        val lifecycleOwner = LocalLifecycleOwner.current

        ScreenshotBox(screenshotState = screenshotState) {
            AndroidView(
                factory = { ctx ->
                    val previewView = PreviewView(ctx)
                    val cameraProviderFuture = ProcessCameraProvider.getInstance(ctx)

                    cameraProviderFuture.addListener({
                        val cameraProvider = cameraProviderFuture.get()

                        val preview = Preview.Builder()
                            .build()

                        // For High end device
                        // android.util.Size(1080, 1440),
                        // Mid-Low End
                        // android.util.Size(720, 960),
                        //

                        val resolutionSelector1 = ResolutionSelector.Builder()
                            .setResolutionStrategy(
                                ResolutionStrategy(
                                    Size(1080, 1440), // ความละเอียดที่ต้องการ
                                    ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER_THEN_LOWER // fallback หากไม่รองรับ
                                )
                            )
                            .build()

                        val imageAnalysis = ImageAnalysis.Builder()
                            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                            .setResolutionSelector(resolutionSelector1)
                            .build()

                        imageAnalysis.setAnalyzer(Executors.newSingleThreadExecutor()) { imageProxy ->
                           // ใช้ Image Proxy ที่นี่

                            //imageProxy.close()
                        }

                        val cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA

                        cameraProvider.bindToLifecycle(
                            lifecycleOwner,
                            cameraSelector,
                            preview,
                            imageAnalysis
                        )
                        preview.setSurfaceProvider(previewView.surfaceProvider)
                    }, ContextCompat.getMainExecutor(ctx))

                    previewView
                },
                modifier = modifier
                    .fillMaxWidth()
                    .aspectRatio(4f / 3f)
            )
        }
    }

    private fun checkAndRequestCameraPermission() {
        if (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED
            } else {
                TODO("VERSION.SDK_INT < M")
            }
        ) {
            Log.d("NativeDemo", "Permission not granted. Requesting permission.")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                requestPermissions(arrayOf(Manifest.permission.CAMERA), CAMERA_REQUEST_CODE)
            }
        } else {
            Log.d("NativeDemo", "Permission already granted. Proceeding with photo capture.")
            // capturePhoto()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        cameraExecutor.shutdown()
    }
}