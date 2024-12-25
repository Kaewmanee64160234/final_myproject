package com.example.identity_scan

import android.Manifest
import android.annotation.SuppressLint
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.Rect
import android.graphics.YuvImage
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
import androidx.camera.core.ImageCaptureException
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
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
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
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
import androidx.compose.ui.window.Dialog
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.example.identity_scan.ml.ModelFront
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.tensorflow.lite.DataType
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.io.File
import androidx.compose.ui.graphics.asImageBitmap
import io.flutter.embedding.engine.dart.DartExecutor

class RectPositionViewModel : ViewModel() {
    private val _rectPosition = MutableLiveData<Rect>()

    fun updateRectPosition(left: Float, top: Float, right: Float, bottom: Float) {
        _rectPosition.value = Rect(left.toInt(), top.toInt(), right.toInt(), bottom.toInt())
    }
}

class CameraViewModel : ViewModel() {
    // Initial Guide Text
    var guideText by mutableStateOf("กรุณาวางบัตรในกรอบ")
        private set

    // Function to update the guide text
    fun updateGuideText(newText: String) {
        guideText = newText
    }
}

class ScanFrontActivity : AppCompatActivity() {
    private lateinit var cameraExecutor: ExecutorService
    private val CAMERA_REQUEST_CODE = 2001
    private val cameraViewModel: CameraViewModel by viewModels()
    private val rectPositionViewModel: RectPositionViewModel by viewModels()
    private var isShutter =  false
    private val imageCapture = ImageCapture.Builder()
        .setTargetAspectRatio(AspectRatio.RATIO_4_3)
        .build()

    private lateinit var model: ModelFront
    private var isProcessing = false
    private var lastProcessedTime: Long = 0
    private var isFound = false
    private lateinit var flutterEngine: FlutterEngine
    private lateinit var methodChannel: MethodChannel

    private val CHANNEL = "camera"


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        cameraExecutor = Executors.newSingleThreadExecutor()
        checkPermissions()
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
                isShutter = true
                result.success("Image Captured Successfully")
            } else {
                result.notImplemented()
            }
        }

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

                    Row(

                    ){
                        Box(
                        ) {
                            Button(onClick = { finish() }) {
                                Text("Exit")
                            }
                        }

                        Box(
                        ) {
                            Button(onClick = { captureImage(imageCapture) }) {
                                Text("Capture")
                            }
                        }

                        Box(
                        ) {
                            Button(onClick = { isShutter = !isShutter}) {
                                Text("Toggle Camera")
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

        val showDialog = remember { mutableStateOf(false) } // ควบคุมการแสดง Dialog
        var bitmapToShow: Bitmap? by remember { mutableStateOf(null) } // ใช้เก็บ bitmap ที่จะแสดง

        val context = LocalContext.current
        var shutterTime = 0
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
                    imageAnalysis.setAnalyzer(backgroundExecutor) { imageProxy ->
                        if(!isProcessing){
                            // ถ้าไม่มีการร้องขอการถ่ายภาพ
                            if(!isShutter){
                                processImageProxy(imageProxy)
                            }else{
//                                println("Shutter Trigger")
                                if(shutterTime < 1 ){

                                    val rgbData = yuvProxyToRgb(imageProxy)
                                    val bitmap = byteArrayToBitmap(rgbData, imageProxy.width, imageProxy.height)

                                    val rotatedBitmap = rotateBitmap(bitmap, 90f)

                                    // Now, crop the image based on the credit card aspect ratio
                                    val croppedBitmap = cropToCreditCardAspectRatio(rotatedBitmap)
            
//                                    ShowImageDialog(bitmap = bitmap)
                                      // เก็บ Bitmap เพื่อนำไปแสดงใน Dialog
                                    bitmapToShow = croppedBitmap
                                    showDialog.value = true 
                                
//                                    sendImageToFlutter(imageProxy)
                                    shutterTime = 1
//                                    finish()

                                }
                            }
                        }

                        imageProxy.close()
                    }



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
        if (showDialog.value && bitmapToShow != null) {
            ShowImageDialog(bitmap = bitmapToShow!!)
        }
    }


    // ฟังก์ชันแปลง RGB ByteArray เป็น Bitmap
    private fun byteArrayToBitmap(rgbData: ByteArray, width: Int, height: Int): Bitmap {
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        var pixelIndex = 0

        for (y in 0 until height) {
            for (x in 0 until width) {
                val r = rgbData[pixelIndex].toInt() and 0xFF
                val g = rgbData[pixelIndex + 1].toInt() and 0xFF
                val b = rgbData[pixelIndex + 2].toInt() and 0xFF

                val color = (0xFF shl 24) or (r shl 16) or (g shl 8) or b
                bitmap.setPixel(x, y, color)

                pixelIndex += 3
            }
        }

        return bitmap
    }

    // ฟังก์ชันที่จะแสดงภาพใน Dialog หรือ Popup ใน Jetpack Compose
    @Composable
    fun ShowImageDialog(bitmap: Bitmap) {
        Dialog(onDismissRequest = {}) {
            Image(
                bitmap = bitmap.asImageBitmap(),
                contentDescription = "Captured Image",
                modifier = Modifier.fillMaxSize()
            )
        }
    }

    private fun yuvProxyToRgb(imageProxy: ImageProxy): ByteArray {
        // Extract YUV planes from ImageProxy
        val yPlane = imageProxy.planes[0].buffer
        val uPlane = imageProxy.planes[1].buffer
        val vPlane = imageProxy.planes[2].buffer

        // Extract width and height from ImageProxy
        val width = imageProxy.width
        val height = imageProxy.height

        // Allocate RGB byte array
        val rgbData = ByteArray(width * height * 3)

        // Get the Y, U, and V planes' bytes
        val yData = ByteArray(yPlane.remaining())
        yPlane.get(yData)

        val uData = ByteArray(uPlane.remaining())
        uPlane.get(uData)

        val vData = ByteArray(vPlane.remaining())
        vPlane.get(vData)

        var rgbIndex = 0
        for (y in 0 until height) {
            for (x in 0 until width) {
                // Calculate Y, U, V indices for the current pixel
                val yIndex = y * width + x
                val uIndex = (y / 2) * (width / 2) + (x / 2) // U plane is downscaled by a factor of 2
                val vIndex = uIndex // V plane is the same as U in YUV420

                // Get Y, U, V values
                val Y = yData[yIndex].toInt() and 0xFF
                val U = uData[uIndex].toInt() and 0xFF - 128
                val V = vData[vIndex].toInt() and 0xFF - 128

                // RGB conversion formula
                var R = (Y + 1.402 * V).toInt()
                var G = (Y - 0.344136 * U - 0.714136 * V).toInt()
                var B = (Y + 1.772 * U).toInt()

                // Clamping RGB values to be between 0 and 255
                R = R.coerceIn(0, 255)
                G = G.coerceIn(0, 255)
                B = B.coerceIn(0, 255)

                // Set the RGB values in the output byte array
                rgbData[rgbIndex] = R.toByte()
                rgbData[rgbIndex + 1] = G.toByte()
                rgbData[rgbIndex + 2] = B.toByte()

                rgbIndex += 3
            }
        }

        return rgbData
    }

    private fun bitmapToByteArray(bitmap: Bitmap): ByteArray {
        val byteArrayOutputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, byteArrayOutputStream)
        return byteArrayOutputStream.toByteArray()
    }

    private fun yuvToRgb(yuvImage: Image): Bitmap? {
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
        // Crop Image to square before processing further
        isProcessing = true
        try {
            // Get the current time
            val currentTime = System.currentTimeMillis()

            // Check if 350 milliseconds have passed since the last processing
            if (currentTime - lastProcessedTime >= 350) {
                lastProcessedTime = currentTime

                val image = imageProxy.image
                if (image != null) {
                    // Convert YUV to Bitmap
                    val bitmap = yuvToRgb(image)  
                    if (bitmap != null) {
                        // Crop the Bitmap to a square (center-crop)
//                        val croppedBitmap = cropToCreditCardAspect(bitmap, imageProxy)
                        // แก้ฟังก์ชัน Crop ที่นี่

                        val rotatedBitmap = rotateBitmap(bitmap, 90f)

                        // Now, crop the image based on the credit card aspect ratio
                        val croppedBitmap = cropToCreditCardAspectRatio(rotatedBitmap)

                        if (croppedBitmap != null) {
                            // Process the cropped Bitmap
                            val byteArray = bitmapToByteArray(croppedBitmap)
                            val outputBuffer = processImage(byteArray)

                            if (outputBuffer != null) {
                                val outputArray = outputBuffer.floatArray
                                // println(outputArray)
                                val maxIndex = outputArray.indices.maxByOrNull { outputArray[it] } ?: -1

                                // Check for the condition "พบบัตร" (Found the card)
                                if (maxIndex == 0) {
                                    cameraViewModel.updateGuideText("พบบัตร")
                                } else {
                                    cameraViewModel.updateGuideText("กรุณาวางบัตรในกรอบ")
                                    isFound = false
                                }
                            } else {
                                println("Error: Process Fail")
                            }
                        } else {
                            println("Error: Cropped Bitmap is null.")
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

    private fun processImage(imageBytes: ByteArray): TensorBuffer? {
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


//    private fun captureImage(imageCapture: ImageCapture) {
//        // Define the output file
//        val photoFile = File(
//            externalMediaDirs.firstOrNull(),
//            "IMG_${System.currentTimeMillis()}.jpg"
//        )
//
//        // Set up output options to save the image
//        val outputOptions = ImageCapture.OutputFileOptions.Builder(photoFile).build()
//
//        // Take the picture
//        imageCapture.takePicture(
//            outputOptions,
//            ContextCompat.getMainExecutor(this),
//            object : ImageCapture.OnImageSavedCallback {
//                override fun onImageSaved(outputFileResults: ImageCapture.OutputFileResults) {
//                    // Get the saved URI of the captured image
//                    val savedUri = outputFileResults.savedUri ?: Uri.fromFile(photoFile)
//
//                    // Optionally, read the image bytes (if needed for further processing)
//                    val byteArray = photoFile.readBytes()
//                    val byteList = byteArray.toList()
//                    println("Captured Image Byte Data: $byteList")
//
//                }
//
//                override fun onError(exception: ImageCaptureException) {
//                    // Handle any errors that occur during image capture
//                }
//            }
//        )
//    }


    private fun captureImage(imageCapture: ImageCapture) {
        // Define the output file
        val photoFile = File(
            externalMediaDirs.firstOrNull(),
            "IMG_${System.currentTimeMillis()}.jpg"
        )

        // Set up output options to save the image
        val outputOptions = ImageCapture.OutputFileOptions.Builder(photoFile).build()

        // Take the picture
        imageCapture.takePicture(
            outputOptions,
            ContextCompat.getMainExecutor(this),
            object : ImageCapture.OnImageSavedCallback {
                override fun onImageSaved(outputFileResults: ImageCapture.OutputFileResults) {

                    // Optionally, read the image bytes (if needed for further processing)
                    val byteArray = photoFile.readBytes()

                    // Convert the byte array to a Bitmap
                    val bitmap = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)

                    // Rotate the Bitmap if necessary (example: rotating by 90 degrees)
                    val rotatedBitmap = rotateBitmap(bitmap, 90f)

                    // Now, crop the image based on the credit card aspect ratio
                    val croppedBitmap = cropToCreditCardAspectRatio(rotatedBitmap)

                    // Optionally, save or display the croppedBitmap
                    saveCroppedImage(croppedBitmap)

                    println("Captured and cropped image saved.")
                }

                override fun onError(exception: ImageCaptureException) {
                    // Handle any errors that occur during image capture
                    exception.printStackTrace()
                }
            }
        )
    }


    private fun rotateBitmap(bitmap: Bitmap, rotationDegrees: Float): Bitmap {
        val matrix = android.graphics.Matrix()
        matrix.postRotate(rotationDegrees) // Rotate the bitmap by the given angle
        return Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
    }

    private fun getRotationDegrees(imageProxy: ImageProxy): Int {
        // Get the rotation degree from the imageProxy
        return when (imageProxy.imageInfo.rotationDegrees) {
            0 -> 0
            90 -> 90
            180 -> 180
            270 -> 270
            else -> 0
        }
    }


    private fun cropToCreditCardAspectRatio(bitmap: Bitmap): Bitmap? {
        val creditCardAspectRatio = 3.37f / 2.125f // Aspect ratio 3.37:2.125

        // Get the bitmap's width and height
        val width = bitmap.width
        val height = bitmap.height

        // Calculate the width and height of the rectangle (bounding box)
        val rectWidth = width * 0.7f // Set width to 70% of image width
        val rectHeight = rectWidth / creditCardAspectRatio // Calculate height based on aspect ratio

        // Center the rectangle in the image
        val rectLeft = (width - rectWidth) / 2
        val rectTop = (height - rectHeight) / 2

        // Calculate the crop area
        val rectRight = rectLeft + rectWidth
        val rectBottom = rectTop + rectHeight

        // Crop the Bitmap according to the calculated rectangle area
        return Bitmap.createBitmap(
            bitmap,
            rectLeft.toInt(),
            rectTop.toInt(),
            rectWidth.toInt(),
            rectHeight.toInt()
        )
    }

    private fun saveCroppedImage(croppedBitmap: Bitmap?) {
        // Save the cropped image to a file or display it as needed
        croppedBitmap?.let {
            val croppedFile = File(externalMediaDirs.firstOrNull(), "Cropped_${System.currentTimeMillis()}.jpg")
            val outputStream = croppedFile.outputStream()

            // Compress the bitmap and save it to the file
            it.compress(Bitmap.CompressFormat.JPEG, 100, outputStream)
            outputStream.close()

            println("Cropped image saved to: ${croppedFile.absolutePath}")
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
                // ขนาดบัตรเครดิตในอัตราส่วน
                val creditCardAspectRatio = 3.37f / 2.125f // อัตราส่วน 3.37:2.125

                // ใช้ขนาดของหน้าจอในการคำนวณขนาดกรอบ
                val rectWidth = size.width * 0.7f // ขนาดความกว้างของกรอบเป็น 70% ของความกว้างหน้าจอ
                val rectHeight = rectWidth / creditCardAspectRatio // คำนวณความสูงจากอัตราส่วนของบัตรเครดิต

                // ทำให้กรอบอยู่ตรงกลาง
                val rectLeft = (size.width - rectWidth) / 2
                val rectTop = (size.height - rectHeight) / 2

                val cornerRadius = 16.dp.toPx() // กำหนดขนาดมุมโค้ง

                // คำนวณค่าของ right และ bottom
                val rectRight = rectLeft + rectWidth
                val rectBottom = rectTop + rectHeight


                // วาดกรอบด้วยมุมโค้ง
                drawRoundRect(
                    color = Color.Gray,
                    topLeft = Offset(rectLeft, rectTop),
                    size = Size(rectWidth, rectHeight),
                    cornerRadius = CornerRadius(cornerRadius, cornerRadius),
                    style = Stroke(width = 4f) // กำหนดความหนาของเส้นขอบ
                )

                rectPositionViewModel.updateRectPosition(rectLeft, rectTop, rectRight, rectBottom)
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
