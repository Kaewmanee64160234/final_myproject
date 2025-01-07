package com.example.identity_scan

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Bitmap
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
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
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
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.opencv.android.Utils
import org.opencv.core.Core
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.MatOfDouble
import org.opencv.core.MatOfPoint
import org.opencv.imgproc.Imgproc
import java.io.File
import java.io.FileOutputStream
import java.nio.ByteBuffer
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import kotlin.math.log

class OpenCVActivity : AppCompatActivity() {
    private lateinit var cameraExecutor: ExecutorService
    private val CAMERA_REQUEST_CODE = 2001
    private lateinit var model: ModelUnquant
    private lateinit var flutterEngine: FlutterEngine
    private lateinit var methodChannel: MethodChannel
    private val CHANNEL = "camera"
    private var statusMessage = mutableStateOf("Lighting conditions are optimal.")


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

        // install open cv
        if (!org.opencv.android.OpenCVLoader.initDebug()) {
            Log.e("OpenCV", "OpenCV initialization failed")
        } else {
            Log.d("OpenCV", "OpenCV initialization successful")
        }

        setContent {
            var statusMessage = remember { mutableStateOf("Align your card here") }

            // Animation for the border
            val infiniteTransition = rememberInfiniteTransition()
            val borderAlpha by infiniteTransition.animateFloat(
                initialValue = 0.4f,
                targetValue = 1.0f,
                animationSpec = infiniteRepeatable(
                    animation = tween(1000, easing = LinearEasing),
                    repeatMode = RepeatMode.Reverse
                )
            )

            Surface(
                modifier = Modifier.fillMaxSize(),
                color = Color(0xFF121212) // Dark background
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(16.dp) // Padding for the entire layout
                ) {
                    // Camera Preview
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .align(Alignment.Center) // Center the camera preview
                    ) {
                        CameraPreview(
                            modifier = Modifier
                                .fillMaxWidth()
                                .aspectRatio(4f / 3f) // Maintain the aspect ratio
                                .align(Alignment.Center), // Ensure it is centered
                            statusMessage = statusMessage // Pass status message to preview
                        )
                    }

                    // Overlay with Rectangle and Text
                    Column(
                        modifier = Modifier
                            .fillMaxSize(),
                        verticalArrangement = Arrangement.Center,
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        // Text above the rectangle
                        Text(
                            text = statusMessage.value,
                            style = TextStyle(
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Medium,
                                color = Color.White
                            ),
                            modifier = Modifier
                                .padding(bottom = 8.dp)
                        )

                        // Rectangle Overlay with Animated Border
                        Box(
                            modifier = Modifier
                                .size(300.dp, 200.dp) // Adjust rectangle size
                                .border(
                                    width = 3.dp,
                                    color = Color.White.copy(alpha = borderAlpha), // Animated border
                                    shape = RoundedCornerShape(8.dp)
                                )
                        )
                    }

                    // Exit Button Section at Bottom
                    Button(
                        onClick = { finish() },
                        modifier = Modifier
                            .fillMaxWidth()
                            .align(Alignment.BottomCenter) // Align button to the bottom
                            .padding(vertical = 16.dp)
                            .clip(RoundedCornerShape(8.dp)), // Rounded button design
                        colors = ButtonDefaults.buttonColors(
                            containerColor = Color(0xFFBB86FC) // Purple accent
                        )
                    ) {
                        Text(
                            text = "Exit",
                            style = TextStyle(
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold,
                                color = Color.White
                            )
                        )
                    }
                }
            }
        }







    }
    @Composable
    fun CameraPreview(
        modifier: Modifier = Modifier,
        statusMessage: MutableState<String>
    ) {
        val screenshotState = rememberScreenshotState()
        val context = LocalContext.current
        val lifecycleOwner = LocalLifecycleOwner.current
        var lastAnalysisTime = System.currentTimeMillis()

        Box(
            modifier = modifier.fillMaxSize()
        ) {
            // Camera Preview
            ScreenshotBox(screenshotState = screenshotState) {
                AndroidView(
                    factory = { ctx ->
                        val previewView = PreviewView(ctx)
                        val cameraProviderFuture = ProcessCameraProvider.getInstance(ctx)

                        cameraProviderFuture.addListener({
                            val cameraProvider = cameraProviderFuture.get()

                            val preview = Preview.Builder().build()

                            val resolutionSelector = ResolutionSelector.Builder()
                                .setResolutionStrategy(
                                    ResolutionStrategy(
                                        Size(1080, 1440),
                                        ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER_THEN_LOWER
                                    )
                                )
                                .build()

                            val imageAnalysis = ImageAnalysis.Builder()
                                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                                .setResolutionSelector(resolutionSelector)
                                .build()

                            imageAnalysis.setAnalyzer(Executors.newSingleThreadExecutor()) { imageProxy ->
                                val currentTime = System.currentTimeMillis()
                                if (currentTime - lastAnalysisTime >= 1000) { // Throttle to 1 second
                                    lastAnalysisTime = currentTime

                                    try {
                                        // Get the YUV data from ImageProxy
                                        val yBuffer = imageProxy.planes[0].buffer // Y plane
                                        val uBuffer = imageProxy.planes[1].buffer // U plane
                                        val vBuffer = imageProxy.planes[2].buffer // V plane

                                        val ySize = yBuffer.remaining()
                                        val uSize = uBuffer.remaining()
                                        val vSize = vBuffer.remaining()

                                        val nv21 = ByteArray(ySize + uSize + vSize)

                                        // Copy Y, U, and V data into NV21 format
                                        yBuffer.get(nv21, 0, ySize)
                                        vBuffer.get(nv21, ySize, vSize)
                                        uBuffer.get(nv21, ySize + vSize, uSize)

                                        // Convert NV21 to Mat
                                        val yuvMat = Mat(
                                            imageProxy.height + imageProxy.height / 2,
                                            imageProxy.width,
                                            CvType.CV_8UC1
                                        )
                                        yuvMat.put(0, 0, nv21)

                                        val rgbMat = Mat()
                                        Imgproc.cvtColor(yuvMat, rgbMat, Imgproc.COLOR_YUV2RGB_NV21)

                                        // Process the RGB Mat for brightness and glare
                                        val avgBrightness = calculateBrightness(rgbMat)
                                        val avgGlare = analyzeBrightRegions(rgbMat)
                                        Log.e("OpenCV Brightness", avgBrightness.toString())
                                        Log.e("OpenCV Glare", avgGlare.toString())

                                        // Update the status message based on conditions
                                        CoroutineScope(Dispatchers.Main).launch {
                                            statusMessage.value = when {
                                                avgBrightness < 70 -> "Brightness too low. Increase lighting."
                                                avgBrightness > 155 -> "Brightness too high. Reduce lighting."
                                                avgGlare > 20.0 -> "High glare detected. Adjust lighting."
                                                else -> "Lighting conditions are optimal."
                                            }
                                        }

                                        // Perform your calculations here using avgBrightness and avgGlare
                                        // For example, trigger further logic if conditions are good
                                        if (avgBrightness in 70.0..140.0 && avgGlare <= 20.0) {
                                            Log.d("ConditionCheck", "Optimal conditions met for further calculations.")
                                            // Add any additional calculation logic here
                                        }

                                        // Release resources
                                        yuvMat.release()
                                        rgbMat.release()
                                    } catch (e: Exception) {
                                        e.printStackTrace()
                                    } finally {
                                        imageProxy.close()
                                    }
                                } else {
                                    imageProxy.close()
                                }
                            }



                            cameraProvider.bindToLifecycle(
                                lifecycleOwner,
                                CameraSelector.DEFAULT_BACK_CAMERA,
                                preview,
                                imageAnalysis
                            )
                            preview.setSurfaceProvider(previewView.surfaceProvider)
                        }, ContextCompat.getMainExecutor(ctx))

                        previewView
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .aspectRatio(4f / 3f)
                )
            }
        }
    }
    private fun saveFrame(rgbMat: Mat) {
        // Convert Mat to Bitmap
        val bitmap = Bitmap.createBitmap(rgbMat.width(), rgbMat.height(), Bitmap.Config.ARGB_8888)
        Utils.matToBitmap(rgbMat, bitmap)

        // Save Bitmap to file (example implementation)
        val file = File(this.filesDir, "captured_frame.jpg")
        FileOutputStream(file).use { out ->
            bitmap.compress(Bitmap.CompressFormat.JPEG, 90, out)
        }

        Log.d("SaveFrame", "Frame saved to ${file.absolutePath}")
    }


    @Composable
    fun RectangleOverlay(
        modifier: Modifier = Modifier
    ) {
        Box(
            modifier = modifier
                .size(300.dp, 200.dp) // Set rectangle dimensions
                .border(3.dp, Color.Red, RoundedCornerShape(8.dp)) // Styled border
        )
    }

    // function for preprocssing
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
    private fun calculateLaplacianVariance(mat: Mat): Double {
        val laplacian = Mat()
        Imgproc.Laplacian(mat, laplacian, mat.depth())

        val mean = MatOfDouble()
        val stddev = MatOfDouble()

        // Correct call to Core.meanStdDev
        Core.meanStdDev(laplacian, mean, stddev)

        val variance = stddev[0, 0][0] * stddev[0, 0][0] // Variance = (StdDev)^2
        laplacian.release()

        return variance
    }
    private fun analyzeBrightRegions(mat: Mat): Double {
        val gray = Mat()
        Imgproc.cvtColor(mat, gray, Imgproc.COLOR_BGR2GRAY)

        val binary = Mat()
        Imgproc.threshold(gray, binary, 230.0, 255.0, Imgproc.THRESH_BINARY)

        val contours = ArrayList<MatOfPoint>()
        val hierarchy = Mat()
        Imgproc.findContours(binary, contours, hierarchy, Imgproc.RETR_EXTERNAL, Imgproc.CHAIN_APPROX_SIMPLE)

        var glareArea = 0.0
        for (contour in contours) {
            val area = Imgproc.contourArea(contour)
            if (area > 500) {
                glareArea += area
            }
        }

        gray.release()
        binary.release()
        return glareArea
    }


    private fun calculateBrightness(mat: Mat): Double {
        val gray = Mat()
        Imgproc.cvtColor(mat, gray, Imgproc.COLOR_BGR2GRAY)
        val meanIntensity = Core.mean(gray).`val`[0]
        gray.release()
        return meanIntensity
    }


    override fun onDestroy() {
        super.onDestroy()
        cameraExecutor.shutdown()
    }
}


    
