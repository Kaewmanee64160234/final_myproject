package com.example.identity_scan

import android.Manifest
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Matrix
import android.graphics.Rect
import android.os.Build
import android.os.Bundle
import android.os.CountDownTimer
import android.util.Log
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.core.resolutionselector.ResolutionStrategy
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
import androidx.compose.ui.platform.LocalLifecycleOwner
import com.smarttoolfactory.screenshot.ScreenshotBox
import com.smarttoolfactory.screenshot.rememberScreenshotState
import io.flutter.embedding.engine.dart.DartExecutor
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.material.MaterialTheme.colors
import androidx.compose.material3.ButtonDefaults
import java.io.FileOutputStream
import java.io.OutputStream


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
    private val imageCapture = ImageCapture.Builder()
        .build()

    private lateinit var model: ModelFront
    private var isProcessing = false
    private var lastProcessedTime: Long = 0
    private var isFound = false
    private lateinit var flutterEngine: FlutterEngine
    private lateinit var methodChannel: MethodChannel
    private val CHANNEL = "camera"
    private val dbHelper = DatabaseHelper(this)



    private var isTiming = false


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
//                isShutter = true
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
                            .padding(top = 40.dp),
                            text = "สแกนหน้าบัตร",
                            color = Color.White,
                            style = TextStyle(fontSize = 20.sp, fontWeight = FontWeight.Bold)
                        )
                    }

                    CameraWithOverlay(modifier = Modifier.weight(1f), guideText = cameraViewModel.guideText)

                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(100.dp),
                        horizontalArrangement = Arrangement.Center,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box(
                            modifier = Modifier
                                .wrapContentSize(Alignment.Center)
                        ) {
                            Button(
                                onClick = { finish() },
                                colors = ButtonDefaults.buttonColors(Color.Red)
                            ) {
                                Text(
                                    text = "ยกเลิก",
                                    color = Color.White,
                                    fontSize = 16.sp
                                )
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
        val screenshotState = rememberScreenshotState()
        var bitmapToShow by remember { mutableStateOf<Bitmap?>(null) }
        var isShutter by remember { mutableStateOf(false) }
        var showDialog by remember { mutableStateOf(false) }
        var base64Image2 by remember { mutableStateOf("No Value") }

        val context = LocalContext.current
        val lifecycleOwner = LocalLifecycleOwner.current

         val timer = object : CountDownTimer(2000, 800) {
            override fun onTick(millisUntilFinished: Long) {
                println("Time remaining: ${millisUntilFinished / 800} seconds")
            }
            override fun onFinish() {
                println("Founded For 1S")
                isShutter = true
            }
        }

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
                                    android.util.Size(1080, 1440), // ความละเอียดที่ต้องการ
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
//                                 println("Converting to Bitmap")
                                 bitmapToShow = imageProxy.toBitmap()

                                 // Update รูปภาพ ที่นี่
                                 val matrix = Matrix()

                                 matrix.postRotate(90f)

                                 bitmapToShow = Bitmap.createBitmap(
                                     bitmapToShow!!, // Original Bitmap
                                     0, 0, // Starting coordinates
                                     bitmapToShow!!.width, // Bitmap width
                                     bitmapToShow!!.height, // Bitmap height
                                     matrix, // The rotation matrix
                                     true // Apply smooth transformation
                                 )

                                 bitmapToJpg(bitmapToShow!!,context,"image.jpg")

                                 showDialog = true
                                 isShutter = false

//                                val imageWidth = imageProxy.width
//                                val imageHeight = imageProxy.height
//                                println("Image Resolution: $imageWidth x $imageHeight")
                             }else{
                                 if (isFound){
                                     if (!isTiming){
                                         isTiming = true
                                         timer.start()
                                     }
                                 }else{
                                     timer.cancel()
                                     isTiming = false
                                     println("Cancelled Timer")
                                 }

                                 processImageProxy(imageProxy)
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

//        Button(
//            onClick = {
//                //ถ่ายรูปที่นี่
//                isShutter = true
//            },
//            modifier = Modifier
//
//                .padding(16.dp)
//        ) {
//            Text("Capture Image")
//        }
        
        // Show Dialog
        if (showDialog && bitmapToShow != null) {
            ShowImageDialog(bitmap = bitmapToShow!!) {
                showDialog = false // Close dialog on dismissal
            }
        }
    }

    fun bitmapToJpg(bitmapImg: Bitmap, context: Context, fileName: String): File {
        // Wrap the context to work with app-specific directories
        val wrapper = ContextWrapper(context)

        // Get the app's private directory for storing images
        var fileDir = wrapper.getDir("Images", Context.MODE_PRIVATE)
        println("Image Directory")
        println(fileDir)
        // Create a file in the directory with the given name
        val file = File(fileDir, fileName)

        try {
            // Create an output stream to write the bitmap data to the file
            val stream: OutputStream = FileOutputStream(file)
            bitmapImg.compress(Bitmap.CompressFormat.JPEG, 100, stream) // Compress to JPEG with quality 25%
            stream.flush()
            stream.close()
        } catch (e: Exception) {
            e.printStackTrace()
        }

        return file
    }

    @Composable
    fun ShowImageDialog(bitmap: Bitmap, onDismiss: () -> Unit) {
        Dialog(onDismissRequest = onDismiss) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp),
                contentAlignment = Alignment.Center // Centers the entire dialog content
            ) {
                Column(
                    modifier = Modifier.wrapContentSize(),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    // Display the image with restricted height
                    Image(
                        bitmap = bitmap.asImageBitmap(),
                        contentDescription = "Captured Image",
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(500.dp) // Adjust height as needed
                            .padding(bottom = 16.dp)
                    )
                    // Display the buttons in a row
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(16.dp), // Space between buttons
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                            // Red Button: "ถ่ายใหม่"
                            Button(
                                onClick = {
                                    isFound = false
                                    onDismiss() // Close the dialog when clicking "ถ่ายใหม่"
                                          },
                                colors = ButtonDefaults.buttonColors(Color.Red)
                            ) {
                                Text(
                                    text = "ถ่ายใหม่",
                                    color = Color.White,
                                    fontSize = 16.sp
                                )
                            }

                            // Default Button: "ใช้ภาพนี้"
                            Button(
                                onClick = {
                                    val resultIntent = Intent()
                                    resultIntent.putExtra("result", "ok") // Pass result data
                                    println("Intent before setResult: ${resultIntent.extras}") // Debugging log
                                    setResult(RESULT_OK, resultIntent) // Return result to the caller
                                    finish() // Close activity
                                }
                            ) {
                                Text(
                                    text = "ใช้ภาพนี้",
                                    fontSize = 16.sp
                                )
                            }
                    }
                }
            }
        }
    }




    private fun updateImageData(newImageData: String) {
        try {
            val db = dbHelper.writableDatabase
            // SQL query to update image_data where id = 1
            val updateQuery = """
            UPDATE images
            SET image_data = ?
            WHERE id = 1
        """.trimIndent()

            // Execute the update query with the new image data
            val statement = db.compileStatement(updateQuery)
            statement.bindString(1, newImageData)  // Bind the parameter
            statement.executeUpdateDelete()  // Execute the update query

            println("Database Image data updated successfully.")
        } catch (e: Exception) {
            e.printStackTrace()
            println("DatabaseError Error while updating data: ${e.message}")
        }
    }

    private fun bitmapToByteArray(bitmap: Bitmap): ByteArray {
        val byteArrayOutputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, byteArrayOutputStream)
        return byteArrayOutputStream.toByteArray()
    }

    // อะไรไม่รู้
    // @SuppressLint("UnsafeOptInUsageError")
    private fun processImageProxy(imageProxy: ImageProxy) {
        // Crop Image to square before processing further
        isProcessing = true
        try {
            // Get the current time
            val currentTime = System.currentTimeMillis()
            // Check if 350 milliseconds have passed since the last processing
            if (currentTime - lastProcessedTime >= 200) {
                lastProcessedTime = currentTime
                // Convert YUV to Bitmap
                val bitmap = imageProxy.toBitmap()
                // Rotate ภาพ
                val rotatedBitmap = rotateBitmap(bitmap, 90f)

                // ตัดภาพตามสัดส่วนบัตรเครดิต
                val croppedBitmap = cropToCreditCardAspectRatio(rotatedBitmap)
                // แก้ให้ไม่ต้องแปลงเป็น ByteArray แต่ให้เป็น Bitmap เลย
                val outputBuffer = processImage(croppedBitmap)

                if (outputBuffer != null) {
                    val outputArray = outputBuffer.floatArray
                    // println(outputArray)
                    val maxIndex = outputArray.indices.maxByOrNull { outputArray[it] } ?: -1

                    if (maxIndex == 0) {
                        // เริ่มจับเวลา 1.5 วินาทีโดยใข้ตัวแปร Local
                        cameraViewModel.updateGuideText("ถือค้างไว้")
                        isFound = true
                    } else {
                        // รีเซ็ตตัวจับเวลา
                        cameraViewModel.updateGuideText("กรุณาวางบัตรในกรอบ")
//                        foundCardTimer = 0
                        isFound = false
                    }
                } else {
                    println("Error: Process Fail")
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            isProcessing = false
            imageProxy.close() // Close the image to allow the next frame to be processed
        }
    }

    private fun processImage(imageBytes: Bitmap): TensorBuffer? {
        try {
//            val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)

            // Check if the bitmap is null
//            if (imageBytes == null) {
//                println("Error: Failed to decode image bytes into Bitmap. ByteArray might be invalid or unsupported format.")
//                return null
//            }

            // Resize the image to the required input size for the model (224x224)
            val height = 224
            val width = 224
            val resizedBitmap = Bitmap.createScaledBitmap(imageBytes, width, height, true)
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



    private fun rotateBitmap(bitmap: Bitmap, rotationDegrees: Float): Bitmap {
        val matrix = Matrix()
        matrix.postRotate(rotationDegrees) // Rotate the bitmap by the given angle
        return Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
    }

    private fun cropToCreditCardAspectRatio(bitmap: Bitmap): Bitmap {
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


        // Crop the Bitmap according to the calculated rectangle area
        return Bitmap.createBitmap(
            bitmap,
            rectLeft.toInt(),
            rectTop.toInt(),
            rectWidth.toInt(),
            rectHeight.toInt()
        )
    }

    @Composable
    fun CameraWithOverlay(modifier: Modifier = Modifier, guideText: String) {
        Box(modifier = modifier) {
            // Camera Preview filling the whole screen
            CameraPreview(modifier = Modifier.fillMaxSize())

            Text(
                text = guideText,
                color = Color.White,
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier
                    .align(Alignment.Center)
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
