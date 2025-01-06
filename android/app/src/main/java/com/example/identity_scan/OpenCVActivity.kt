package com.example.identity_scan

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Matrix
import android.os.Build
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.util.Size
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageCapture
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
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
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
import com.example.identity_scan.ml.ModelFront
import com.smarttoolfactory.screenshot.ScreenshotBox
import com.smarttoolfactory.screenshot.rememberScreenshotState
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class OpenCVActivity : AppCompatActivity() {
    private lateinit var cameraExecutor: ExecutorService
    private val cameraViewModel: CameraViewModel by viewModels()
    private val rectPositionViewModel: RectPositionViewModel by viewModels()
    private val imageCapture = ImageCapture.Builder()
        .build()
    private val CAMERA_REQUEST_CODE = 2001
    private lateinit var model: ModelFront
    private var isProcessing = false
    private var lastProcessedTime: Long = 0
    private var isFound = false
    private lateinit var flutterEngine: FlutterEngine
    private lateinit var methodChannel: MethodChannel
    private val dbHelper = DatabaseHelper(this)
    private val CHANNEL = "camera"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        cameraExecutor = Executors.newSingleThreadExecutor()
        checkAndRequestCameraPermission()
        model = ModelFront.newInstance(this)

        // Initialize FlutterEngine manually
        flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        methodChannel = MethodChannel(flutterEngine.dartExecutor, CHANNEL)

        // Set up the MethodChannel
        MethodChannel(flutterEngine.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "captureImage") {
//                isShutter = true
                result.success("Image Captured Successfully")
            } else {
                result.notImplemented()
            }
        }

        setContent {
            Surface(
                modifier = Modifier.fillMaxSize(),
                color = Color.Black // Explicitly set the background color to black
            ) {
                Column(modifier = Modifier.fillMaxSize()) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.Center
                    ) {
                        Text( modifier = Modifier
                            .height(80.dp)
                            .padding(16.dp),
                            text = "OpenCV View",
                            color = Color.White,
                            style = TextStyle(fontSize = 20.sp, fontWeight = FontWeight.Bold)
                        )
                    }

                    CameraPreview()

                    Row(

                    ){
                        Box(
                        ) {
                            Button(onClick = { finish() }) {
                                Text("Exit")
                            }
                        }
                    }
                }
            }
        }
    }

    @Composable
    fun CameraPreview(modifier: Modifier = Modifier) {
        val screenshotState = rememberScreenshotState()
        var bitmapToShow by remember { mutableStateOf<Bitmap?>(null) }
        var isShutter by remember { mutableStateOf(false) }
        var showDialog by remember { mutableStateOf(false) }
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
                            if (isShutter) {
                                println("Converting to Bitmap")
                                bitmapToShow = imageProxy.toBitmap()

                                // Update รูปภาพ ที่นี่
                                val matrix = Matrix()
//                                 matrix.postRotate(90f)
//                                 bitmapToShow = Bitmap.createBitmap(bitmapToShow!!, 0, 0, bitmapToShow!!.width, bitmapToShow!!.height, matrix, true)
//                                 base64Image  = bitmapToBase64(bitmapToShow)

                                matrix.postRotate(90f)

                                bitmapToShow = Bitmap.createBitmap(
                                    bitmapToShow!!, // Original Bitmap
                                    0, 0, // Starting coordinates
                                    bitmapToShow!!.width, // Bitmap width
                                    bitmapToShow!!.height, // Bitmap height
                                    matrix, // The rotation matrix
                                    true // Apply smooth transformation
                                )

                                // Convert the rotated Bitmap to Base64
//                                 var base64Image = bitmapToBase64(bitmapToShow!!)

//                                bitmapToJpg(bitmapToShow!!,context,"image.jpg")

                                // Update Basse64 sqlite databae
//                                 updateImageData(base64Image)

                                showDialog = true
                                isShutter = false

//                                val imageWidth = imageProxy.width
//                                val imageHeight = imageProxy.height
//                                println("Image Resolution: $imageWidth x $imageHeight")
                            }else{
//                                processImageProxy(imageProxy)
                            }

                            //Ensure to close the imageProxy after processing
                            imageProxy.close()
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

        Button(
            onClick = {
                //ถ่ายรูปที่นี่
                isShutter = true
            },
            modifier = Modifier

                .padding(16.dp)
        ) {
            Text("Capture Image")
        }
        
        // Show Dialog
//        if (showDialog && bitmapToShow != null) {
//            ShowImageDialog(bitmap = bitmapToShow!!) {
//                showDialog = false // Close dialog on dismissal
//            }
//        }
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