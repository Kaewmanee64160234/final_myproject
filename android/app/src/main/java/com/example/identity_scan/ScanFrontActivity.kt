package com.example.identity_scan

import android.Manifest
import android.annotation.SuppressLint
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.Image
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.AspectRatio
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.foundation.Canvas
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
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModel
import com.example.identity_scan.ml.ModelFront
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import android.graphics.ImageFormat
import android.graphics.YuvImage
import android.graphics.Rect
import java.io.ByteArrayOutputStream
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer
import java.nio.ByteBuffer
import org.tensorflow.lite.Interpreter
import java.nio.ByteOrder
import org.tensorflow.lite.DataType


class CameraViewModel : ViewModel() {
    // State to hold the guide text
    var guideText by mutableStateOf("Initial guide text")
        private set

    // Function to update the guide text
    fun updateGuideText(newText: String) {
        guideText = newText
    }
}

class ScanFrontActivity : AppCompatActivity() {
    private lateinit var cameraExecutor: ExecutorService
    private val CAMERA_REQUEST_CODE = 2001
    private val CHANNEL = "camera"
    private var guideText = "กรุณาวางบัตรในกรอบ"
    private val cameraViewModel: CameraViewModel by viewModels()
    private lateinit var model: ModelFront
    private var isProcessing = false;
    private var lastProcessedTime: Long = 0
    private var isFound = false;

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        cameraExecutor = Executors.newSingleThreadExecutor()
        checkPermissions()
        checkAndRequestCameraPermission()
        model = ModelFront.newInstance(this)

        setContent {
            Surface(
                modifier = Modifier.fillMaxSize(),
//                color = MaterialTheme.colorScheme.background
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
                            text = "สแกนหน้าบัตร",
                            color = Color.White,
                            style = TextStyle(fontSize = 20.sp, fontWeight = FontWeight.Bold)
                        )
                    }

                    CameraWithOverlay(modifier = Modifier.weight(1f), guideText = cameraViewModel.guideText)


                    //                        cameraViewModel.updateGuideText("กรุณาถือนิ่งๆ")
//                    Box(
//                    ) {
//                        Button(onClick = { finish() }) {
//                            Text("Exit")
//                        }
//                    }

                    Column(
                        verticalArrangement = Arrangement.Center,
                        horizontalAlignment = Alignment.CenterHorizontally
                    ){
                        Box(
                        ) {
                            Button(onClick = { finish() }) {
                                Text("Exit")
                            }
                        }
                        Box(
                        ) {
                            Button(onClick = { cameraViewModel.updateGuideText("กรุณาถือนิ่งๆ") }) {
                                Text("UpdateText")
                            }
                        }
                    }


                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        cameraExecutor.shutdown()
    }


    @Composable
    fun CameraPreview(modifier: Modifier = Modifier) {
        val context = LocalContext.current

        AndroidView(
            factory = { ctx ->
                val previewView = PreviewView(ctx)
                val cameraProviderFuture = ProcessCameraProvider.getInstance(ctx)

                cameraProviderFuture.addListener({
                    val cameraProvider = cameraProviderFuture.get()

                    // Set up the preview use case with a specific aspect ratio
                    val preview = Preview.Builder()
                        .setTargetAspectRatio(AspectRatio.RATIO_4_3) // Set 4:3 aspect ratio
                        .build()

                    // Set up the image analysis use case to receive ImageProxy
                    val imageAnalysis = ImageAnalysis.Builder()
                        .setTargetAspectRatio(AspectRatio.RATIO_4_3)
                        .setBackpressureStrategy(ImageAnalysis.STRATEGY_BLOCK_PRODUCER) // Prevent buffer overflow
                        .build()

                    val backgroundExecutor = Executors.newSingleThreadExecutor()

                    // Set an analyzer for the imageAnalysis use case
                    imageAnalysis.setAnalyzer(ContextCompat.getMainExecutor(ctx)) { imageProxy ->
//                        Log.d("ImageAnalysis", "Image Proxy received: Width: ${imageProxy.width}, Height: ${imageProxy.height}")

                        // Process the imageProxy here
                         processImageProxy(imageProxy)
                        imageProxy.close()
                    }

                    // Optionally configure ImageCapture for capturing photos
                    val imageCapture = ImageCapture.Builder()
                        .setTargetAspectRatio(AspectRatio.RATIO_4_3) // Match preview's aspect ratio
                        .build()

                    // Choose the back camera as the default
                    val cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA

                    // Bind use cases to the lifecycle
                    cameraProvider.bindToLifecycle(
                        context as ComponentActivity,
                        cameraSelector,
                        preview,
                        imageAnalysis,  // Bind image analysis to the camera lifecycle
                        imageCapture
                    )

                    // Set the surface provider for the preview
                    preview.setSurfaceProvider(previewView.surfaceProvider)
                }, ContextCompat.getMainExecutor(ctx))

                previewView
            },
            modifier = modifier
                .fillMaxWidth()
                .aspectRatio(4f / 3f) // Maintain 4:3 aspect ratio for the composable
        )
    }


    private fun bitmapToByteArray(bitmap: Bitmap): ByteArray {
        val byteArrayOutputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, byteArrayOutputStream)
        return byteArrayOutputStream.toByteArray()
    }

    fun yuvToRgb(yuvImage: Image): Bitmap? {
        val width = yuvImage.width
        val height = yuvImage.height
        val yuvBytes = yuvImage.planes[0].buffer
        val uvBytes = yuvImage.planes[1].buffer

        val yuvByteArray = ByteArray(yuvBytes.remaining())
        yuvBytes.get(yuvByteArray)

        val uvByteArray = ByteArray(uvBytes.remaining())
        uvBytes.get(uvByteArray)

        val yuvImageData = YuvImage(
            yuvByteArray,
            ImageFormat.NV21,
            width,
            height,
            null
        )

        val outStream = ByteArrayOutputStream()
        yuvImageData.compressToJpeg(Rect(0, 0, width, height), 100, outStream)

        val byteArray = outStream.toByteArray()
        return BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)
    }

    // อะไรไม่รู้
    @SuppressLint("UnsafeOptInUsageError")
    private fun processImageProxy(imageProxy: ImageProxy) {
        isProcessing = true
        try {
            // Get the current time
            val currentTime = System.currentTimeMillis()

            // Check if 350 milliseconds have passed since the last processing
            if (currentTime - lastProcessedTime >= 350) {
                lastProcessedTime = currentTime

                val image = imageProxy.image
                if (image != null) {
                    println("Hello")
                    val bitmap = yuvToRgb(image) // Convert YUV to Bitmap
                    if (bitmap != null) {
                        val byteArray = bitmapToByteArray(bitmap)
                        val outputBuffer = processImage(byteArray)

                        if (outputBuffer != null) {
                            val outputArray = outputBuffer.floatArray
                            val maxIndex = outputArray.indices.maxByOrNull { outputArray[it] } ?: -1

                            // Check for the condition "พบบัตร" (Found the card)
//                            val resultTextView: TextView = findViewById(R.id.resultText)
                            if (maxIndex == 0) {
                                Log.d("TAG", "พบ maxIndex: $maxIndex")
                            } else {
                                Log.d("TAG", "ไม่พบ maxIndex: $maxIndex")
                                // resultTextView.text = "ไม่พบ" // Card not found
                                isFound = false
                            }

                        } else {
                            println("Error: Process Fail")
                        }
                    } else {
                        println("Error: Bitmap is null.")
                    }
                } else {
                    println("Error: imageProxy.image is null.")
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            isProcessing = false
            imageProxy.close() // Close the image to allow the next frame to be processed
        }
    }



    fun processImage(imageBytes: ByteArray): TensorBuffer? {
        try {
            // Decode the raw image bytes to a Bitmap
            val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)

            // Check if the bitmap is null
            if (bitmap == null) {
                println("Error: Failed to decode image bytes into Bitmap. ByteArray might be invalid or unsupported format.")
                return null
            }

            // println("Image loaded successfully.")

            // Resize the image to the required input size for the model (224x224)
            val height = 224
            val width = 224
            val resizedBitmap = Bitmap.createScaledBitmap(bitmap, width, height, true)
            // println("Image resized to $width x $height.")

            // Prepare a ByteBuffer to hold image data in the required format (Float32)
            val imageData = ByteBuffer.allocateDirect(4 * height * width * 3) // 3 for RGB channels
            imageData.order(ByteOrder.nativeOrder())

            // Convert image pixels to normalized RGB values and fill the ByteBuffer
            for (y in 0 until height) {
                for (x in 0 until width) {
                    val pixel = resizedBitmap.getPixel(x, y)

                    // Extract RGB values and normalize to [0, 1]
                    val r = (pixel shr 16 and 0xFF) / 255.0f
                    val g = (pixel shr 8 and 0xFF) / 255.0f
                    val b = (pixel and 0xFF) / 255.0f

                    imageData.putFloat(r)
                    imageData.putFloat(g)
                    imageData.putFloat(b)
                }
            }

            // Create input tensor buffer with the required shape
            val inputFeature0 = TensorBuffer.createFixedSize(intArrayOf(1, 224, 224, 3), DataType.FLOAT32)
            inputFeature0.loadBuffer(imageData)

            // Run inference using the already loaded model
            val outputs = model.process(inputFeature0)

            // Extract the output tensor buffer
            val outputFeature0 = outputs.outputFeature0AsTensorBuffer

            // Return the output feature
            return outputFeature0
        } catch (e: Exception) {
            println("Error processing image: ${e.message}")
            e.printStackTrace()
            return null // Return null if an error occurs
        }
    }

    @Composable
    fun CameraWithOverlay(modifier: Modifier = Modifier, guideText: String) {
        Box(modifier = modifier) {
            // Camera Preview filling the whole screen
            CameraPreview(modifier = Modifier.fillMaxSize())


         // สำหรับจัดตำแหน่ง Item
//                modifier = Modifier
//                    .align(Alignment.TopCenter)
//                    .padding(top = 16.dp)
//
            // Overlay Text stacked on top of the Camera Preview
            Text(
                text = guideText,
                color = Color.White,
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier
                    .align(Alignment.Center)
//                    .padding(top = 16.dp)
            )

            Canvas(modifier = Modifier.fillMaxSize()) {
                val rectWidth = size.width * 0.8f // Set rectangle width as 80% of screen width
                val rectHeight = size.height * 0.25f // Set rectangle height as 25% of screen height
                val rectLeft = (size.width - rectWidth) / 2 // Center the rectangle horizontally
                val rectTop = (size.height - rectHeight) / 2 // Center the rectangle vertically

                val cornerRadius = 16.dp.toPx() // Convert corner radius to pixels (adjust as needed)

                drawRoundRect(
                    color = Color.Gray,
                    topLeft = Offset(rectLeft, rectTop),
                    size = Size(rectWidth, rectHeight),
                    cornerRadius = androidx.compose.ui.geometry.CornerRadius(cornerRadius, cornerRadius),
                    style = Stroke(width = 4f) // Optional border width for the rectangle
                )
            }


        }
    }

    private fun checkPermissions() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CAMERA), 0)
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



}
