package com.example.identity_scan

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.YuvImage
import android.os.Build
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.util.Size
import androidx.activity.compose.setContent
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageCaptureException
import androidx.camera.core.ImageProxy
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
import androidx.compose.foundation.Image
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import androidx.lifecycle.lifecycleScope
import coil.compose.rememberImagePainter
import coil.decode.DecodeUtils.calculateInSampleSize
import com.example.identity_scan.ml.ModelUnquant
import com.smarttoolfactory.screenshot.ScreenshotBox
import com.smarttoolfactory.screenshot.rememberScreenshotState
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.opencv.android.Utils
import org.opencv.core.Core
import org.opencv.core.Mat
import org.opencv.core.MatOfDouble
import org.opencv.core.MatOfPoint
import org.opencv.core.Rect
import org.opencv.imgproc.Imgproc
import org.tensorflow.lite.DataType
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class OpenCVActivity : AppCompatActivity() {
    private lateinit var cameraExecutor: ExecutorService
    private val CAMERA_REQUEST_CODE = 2001
    private lateinit var model: ModelUnquant
    private lateinit var flutterEngine: FlutterEngine
    private lateinit var methodChannel: MethodChannel
    private val CHANNEL = "camera"
    private var statusMessage = mutableStateOf("Lighting conditions are optimal.")
    private var imagePathList = mutableStateListOf<String>()
    private lateinit var imageCapture: ImageCapture
    private var captureComplete = false
    private var sharpestImagePath = ""


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
                        if(captureComplete){
                            LazyColumn {
                                sharpestImagePath?.let { path ->
                                    item {
                                        // Decode the image again for display (sampled to e.g. 800x800)
                                        val sampledBitmap = decodeSampledBitmap(path, 800, 800)
                                        if (sampledBitmap != null) {
                                            val mat = bitmapToMat(sampledBitmap)
                                            val variance = mat?.let { calculateLaplacianVariance(it) } ?: 0.0
                                            mat.release()

                                            Column(modifier = Modifier.fillMaxWidth().padding(8.dp)) {
                                                // Show the image (Coil can handle sampling too)
                                                Image(
                                                    painter = rememberImagePainter(path),
                                                    contentDescription = "Captured Image",
                                                    modifier = Modifier
                                                        .fillMaxWidth()
                                                        .height(200.dp)
                                                )

                                            }
                                        } else {
                                            androidx.compose.material.Text(
                                                text = "Failed to load image: $path",
                                                color = Color.Red,
                                                fontSize = 14.sp,
                                                modifier = Modifier.padding(8.dp)
                                            )
                                        }
                                    }
                                }
                            }
                        }
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
    private fun decodeSampledBitmap(path: String, reqWidth: Int, reqHeight: Int): Bitmap? {
        // First decode with inJustDecodeBounds=true to check dimensions
        val options = BitmapFactory.Options().apply {
            inJustDecodeBounds = true
        }
        BitmapFactory.decodeFile(path, options)

        // Calculate inSampleSize
        options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight)

        // Decode bitmap with inSampleSize set
        options.inJustDecodeBounds = false

        return BitmapFactory.decodeFile(path, options)
    }
    private fun calculateInSampleSize(options: BitmapFactory.Options, reqWidth: Int, reqHeight: Int): Int {
        val (height: Int, width: Int) = options.run { outHeight to outWidth }
        var inSampleSize = 1

        if (height > reqHeight || width > reqWidth) {
            val halfHeight: Int = height / 2
            val halfWidth: Int = width / 2

            while ((halfHeight / inSampleSize) >= reqHeight && (halfWidth / inSampleSize) >= reqWidth) {
                inSampleSize *= 2
            }
        }
        return inSampleSize
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

                            // Create Preview use case
                            val preview = Preview.Builder().build()

                            // Create ImageCapture use case
                            val imageCapture = ImageCapture.Builder()
                                .setCaptureMode(ImageCapture.CAPTURE_MODE_MINIMIZE_LATENCY)
                                .build()

                            // Create ImageAnalysis use case
                            val imageAnalysis = ImageAnalysis.Builder()
                                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                                .build()

                            imageAnalysis.setAnalyzer(Executors.newSingleThreadExecutor()) { imageProxy ->
                                if (!captureComplete) {
                                    val currentTime = System.currentTimeMillis()
                                    if (System.currentTimeMillis() - lastAnalysisTime > 1000) {
                                        lastAnalysisTime = System.currentTimeMillis()

                                        try {
                                            // Convert ImageProxy to Bitmap
                                            val bitmap = imageProxyToBitmap(imageProxy)
                                            val resizedBitmap = resizeBitmapTo224x224(bitmap)

                                            // Convert Bitmap to ByteBuffer for TensorFlow Lite
                                            val inputByteBuffer = convertBitmapToByteBuffer(resizedBitmap)

                                            val inputFeature0 = TensorBuffer.createFixedSize(
                                                intArrayOf(1, 224, 224, 3),
                                                DataType.FLOAT32
                                            )
                                            inputFeature0.loadBuffer(inputByteBuffer)
                                            val outputs = model.process(inputFeature0)
                                            val outputFeature0 = outputs.outputFeature0AsTensorBuffer

                                            val predictedClass = outputFeature0.floatArray.indices.maxByOrNull {
                                                outputFeature0.floatArray[it]
                                            } ?: -1
                                            Log.w("Model Prediction", predictedClass.toString())

                                            if (predictedClass == 0) { // Optimal conditions
                                                val mat = bitmapToMat(bitmap)

                                                // Perform brightness and glare analysis
                                                val avgBrightness = calculateBrightness(mat)
                                                val avgGlare = analyzeBrightRegions(mat)

                                                Log.e("OpenCV Brightness", avgBrightness.toString())
                                                Log.e("OpenCV Glare", avgGlare.toString())

                                                val isOptimal = avgBrightness in 70.0..155.0 && avgGlare <= 20.0

                                                CoroutineScope(Dispatchers.Main).launch {
                                                    statusMessage.value = when {
                                                        avgBrightness < 70 -> "Brightness too low. Increase lighting."
                                                        avgBrightness > 155 -> "Brightness too high. Reduce lighting."
                                                        avgGlare > 20.0 -> "High glare detected. Adjust lighting."
                                                        else -> "Lighting conditions are optimal."
                                                    }

                                                    if (isOptimal) {
                                                        delay(2000) // Wait for 2 seconds
                                                        if (statusMessage.value == "Lighting conditions are optimal.") {
                                                            statusMessage.value = "capture !!!"
                                                            captureBurstImages(imageCapture, 5) {
                                                                val (sharpestPath, maxVariance) = findSharpestImage(imagePathList)
                                                                sharpestPath?.let {
                                                                    sharpestImagePath = it
                                                                    statusMessage.value = "Sharpest Image: $it\nVariance: $maxVariance"
                                                                }
                                                            }
                                                            captureComplete = true

                                                        }
                                                    }
                                                }

                                                mat.release()
                                            } else if (predictedClass == 1) {
                                                statusMessage.value = "Please use a Real ID Card"
                                            } else if (predictedClass == 2) {
                                                statusMessage.value = "Please move your hand away from the card"
                                            } else {
                                                statusMessage.value = "Card not found"
                                            }
                                        } catch (e: Exception) {
                                            e.printStackTrace()
                                        } finally {
                                            imageProxy.close()
                                        }
                                    } else {
                                        imageProxy.close()

                                    }
                                }
                            }

                            // Bind use cases to lifecycle
                            cameraProvider.bindToLifecycle(
                                lifecycleOwner,
                                CameraSelector.DEFAULT_BACK_CAMERA,
                                preview,
                                imageCapture,
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

    private fun captureBurstImages(
        imageCapture: ImageCapture,
        totalCaptures: Int = 5,
        onComplete: () -> Unit
    ) {
        if (captureComplete) return // Stop if capture is already complete

        var remainingCaptures = totalCaptures
        val photoFiles = List(totalCaptures) { index ->
            File(externalMediaDirs.firstOrNull(), "IMG_${System.currentTimeMillis()}_$index.jpg")
        }

        photoFiles.forEach { file ->
            Log.d("PhotoFiles", "File Path: ${file.absolutePath}")
        }

        lifecycleScope.launch(Dispatchers.Main) {
            photoFiles.forEach { photoFile ->
                val outputOptions = ImageCapture.OutputFileOptions.Builder(photoFile).build()

                imageCapture.takePicture(
                    outputOptions,
                    ContextCompat.getMainExecutor(this@OpenCVActivity),
                    object : ImageCapture.OnImageSavedCallback {
                        override fun onImageSaved(outputFileResults: ImageCapture.OutputFileResults) {
                            lifecycleScope.launch(Dispatchers.IO) {
                                // Save path
                                imagePathList.add(photoFile.absolutePath)
                                Log.d("Burst", "Image saved: ${photoFile.absolutePath}")

                                // Decrement remaining count
                                remainingCaptures--

                                // If all captures are done, invoke onComplete
                                if (remainingCaptures == 0) {
                                    captureComplete = true // Mark capture as complete
                                    withContext(Dispatchers.Main) {
                                        val (sharpestPath, maxVariance) = findSharpestImage(imagePathList)
                                        sharpestPath?.let {
                                            Log.d("Sharpest Image", "Path: $it, Variance: $maxVariance")
                                        }
                                        onComplete()
                                    }
                                }
                            }
                        }

                        override fun onError(exception: ImageCaptureException) {
                            Log.e("Burst", "Error capturing image: ${exception.message}")
                            remainingCaptures--
                            if (remainingCaptures == 0) {
                                captureComplete = true // Mark capture as complete
                                val (sharpestPath, maxVariance) = findSharpestImage(imagePathList)
                                sharpestPath?.let {
                                    Log.d("Sharpest Image", "Path: $it, Variance: $maxVariance")
                                }
                                onComplete()
                            }
                        }
                    }
                )
            }
        }
    }

    private fun findSharpestImage(imagePaths: List<String>): Pair<String?, Double> {
        var sharpestPath: String? = null
        var maxVariance = 0.0

        for (path in imagePaths) {
            val bitmap = BitmapFactory.decodeFile(path) ?: continue
            val mat = bitmapToMat(bitmap) ?: continue

            if (!mat.empty()) {
                val variance = calculateLaplacianVariance(mat)
                if (variance > maxVariance) {
                    maxVariance = variance
                    sharpestPath = path
                }
                mat.release()


            }
        }

        return Pair(sharpestPath, maxVariance)
    }
    private fun bitmapToMat(bitmap: Bitmap): Mat {
        val mat = Mat() // Create an empty Mat
        Utils.bitmapToMat(bitmap, mat) // Convert Bitmap to Mat

        return mat
    }

    private fun convertBitmapToByteBuffer(bitmap: Bitmap): ByteBuffer {
        val byteBuffer = ByteBuffer.allocateDirect(4 * 224 * 224 * 3) // FLOAT32 has 4 bytes
        byteBuffer.order(ByteOrder.nativeOrder())

        val intValues = IntArray(224 * 224)
        bitmap.getPixels(intValues, 0, bitmap.width, 0, 0, bitmap.width, bitmap.height)

        for (pixel in intValues) {
            val r = (pixel shr 16 and 0xFF) / 255.0f
            val g = (pixel shr 8 and 0xFF) / 255.0f
            val b = (pixel and 0xFF) / 255.0f

            byteBuffer.putFloat(r)
            byteBuffer.putFloat(g)
            byteBuffer.putFloat(b)
        }

        return byteBuffer
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

    private fun imageProxyToBitmap(imageProxy: ImageProxy): Bitmap {
        val yBuffer = imageProxy.planes[0].buffer // Y plane
        val uBuffer = imageProxy.planes[1].buffer // U plane
        val vBuffer = imageProxy.planes[2].buffer // V plane

        val ySize = yBuffer.remaining()
        val uSize = uBuffer.remaining()
        val vSize = vBuffer.remaining()

        val nv21 = ByteArray(ySize + uSize + vSize)

        yBuffer.get(nv21, 0, ySize)
        vBuffer.get(nv21, ySize, vSize)
        uBuffer.get(nv21, ySize + vSize, uSize)

        val yuvImage = YuvImage(nv21, ImageFormat.NV21, imageProxy.width, imageProxy.height, null)
        val out = ByteArrayOutputStream()

        // Use android.graphics.Rect for the compression area
        val rect = android.graphics.Rect(0, 0, imageProxy.width, imageProxy.height)
        yuvImage.compressToJpeg(rect, 100, out)

        val imageBytes = out.toByteArray()
        return BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
    }


    private fun resizeBitmapTo224x224(bitmap: Bitmap): Bitmap {
        return Bitmap.createScaledBitmap(bitmap, 224, 224, true)
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
        Imgproc.findContours(binary, contours, Mat(), Imgproc.RETR_EXTERNAL, Imgproc.CHAIN_APPROX_SIMPLE)

        var glareArea = 0.0
        for (contour in contours) {
            val area = Imgproc.contourArea(contour)
            if (area > 500) { // Ignore small noise
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
        val mean = Core.mean(gray)
        gray.release()
        return mean.`val`[0]
    }




    override fun onDestroy() {
        super.onDestroy()
        cameraExecutor.shutdown()
    }
}


    
