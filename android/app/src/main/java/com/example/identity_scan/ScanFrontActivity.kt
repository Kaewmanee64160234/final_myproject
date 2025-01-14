package com.example.identity_scan

import android.Manifest
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
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
import androidx.compose.material3.ButtonDefaults
import org.opencv.android.Utils
import org.opencv.core.Core
import org.opencv.core.Mat
import org.opencv.core.MatOfDouble
import org.opencv.core.MatOfPoint
import org.opencv.imgproc.Imgproc
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

    var brightnessValueText by mutableStateOf("0")
        private set

    var glareValueText by mutableStateOf("0")
        private set

    // Function to update the guide text
    fun updateGuideText(newText: String) {
        guideText = newText
    }

    fun updateBrightnessValueText(newValue: String) {
        brightnessValueText = newValue
    }

    fun updateGlareValueText(newValue: String) {
        glareValueText = newValue
    }
}

class ScanFrontActivity : AppCompatActivity() {
    private lateinit var cameraExecutor: ExecutorService
    private val CAMERA_REQUEST_CODE = 2001
    private val cameraViewModel: CameraViewModel by viewModels()
    private val rectPositionViewModel: RectPositionViewModel by viewModels()
    private lateinit var model: ModelFront
    private var isProcessing = false
    private var lastProcessedTime: Long = 0
    private var isFound = false
    private lateinit var flutterEngine: FlutterEngine
    private lateinit var methodChannel: MethodChannel
    private val CHANNEL = "camera"
    private val dbHelper = DatabaseHelper(this)
    private var isTiming = false
    // นับภาพที่ Capture จาก 1
    // จัดเก็บ Bitmap ของรูปภาพทั้ง 5
    private val bitmapList: MutableList<Bitmap> = mutableListOf()
    private var sharPestImageIndex = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        cameraExecutor = Executors.newSingleThreadExecutor()
        checkPermissions()
        checkAndRequestCameraPermission()
//        model = ModelFront.newInstance(this)
        model = ModelFront.newInstance(this)

        if (!org.opencv.android.OpenCVLoader.initDebug()) {
            Log.e("OpenCV", "OpenCV initialization failed")
        } else {
            Log.d("OpenCV", "OpenCV initialization successful")
        }

        // Initialize FlutterEngine manually
        flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        methodChannel = MethodChannel(flutterEngine.dartExecutor, CHANNEL)

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
                             // ถ้ามีคำสั่งให้ถ่ายรูป ค่าเริ่มต้นปกติคือ false ดังนั้นโปรแกรมจะวิ่งไปที่ Else ก่อนเสมอ
                             if (isShutter) {

                                 //bitmapToShow = cropToCreditCardAspectRatio()


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

                                 // ถ้าภาพยังไม่ครบ 3 ภาพ
                                 if (bitmapList.size < 3 ){
                                     // เพิ่มรูป Bitmap เข้า List จนกว่าจะครบ 3 รูป
                                     bitmapList.add(bitmapList.size,bitmapToShow!!)
                                     bitmapToJpg(bitmapToShow!!,context,"image${bitmapList.size.toString()}.jpg")
                                     if(bitmapList.size == 3){
                                         // ถ้าครบ 3 รูปแล้วให้หารูปที่คมชัดที่สุด จาก Bitmap List
                                         var sharPestImage = findSharpestImage()
                                         println("Sharpest Image Index is: ${sharPestImage.first}, Variance: ${sharPestImage.second}")

                                         // บันทึก Index ของภาพที่ชัดที่สุด ไว้ในตัวแปร
                                         sharPestImageIndex = sharPestImage.first!!

                                         // เสร็จแล้วแสดงภาพที่ชัดที่สุดออกมา
                                         showDialog = true
                                         isShutter = false
                                     }
                                 }
//                                การ Print ขนาดของ Image Proxy
//                               val imageWidth = imageProxy.width
//                               val imageHeight = imageProxy.height
//                               println("Image Resolution: $imageWidth x $imageHeight")
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

                             // ปิด Image Proxy หลัง Process เสร็จ
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

        // Show Dialog
        if (showDialog && bitmapToShow != null) {
            ShowImageDialog(bitmap = bitmapToShow!!) {
                showDialog = false
                // Clear Bitmap List หลังจากปิด Dialog
                bitmapList.clear()
            }
        }
    }

    fun bitmapToJpg(bitmapImg: Bitmap, context: Context, fileName: String): File {
        // Wrap the context to work with app-specific directories
        val wrapper = ContextWrapper(context)

        // Get the app's private directory for storing images
        val fileDir = wrapper.getDir("Images", Context.MODE_PRIVATE)
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

    private fun findSharpestImage(): Pair<Int?, Double> {
        var sharpestIndex: Int? = null
        var maxVariance = 0.0

        for (i in bitmapList.indices) {
            val bitmap = bitmapList[i]
            val mat = bitmapToMat(bitmap) ?: continue

            if (!mat.empty()) {
                val variance = calculateLaplacianVariance(mat)
                if (variance > maxVariance) {
                    maxVariance = variance
                    sharpestIndex = i
                }
                mat.release()
            }
        }

        return Pair(sharpestIndex, maxVariance)
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
                                    resultIntent.putExtra("result", sharPestImageIndex.toString())
                                    setResult(RESULT_OK, resultIntent)
                                    finish()
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

    private fun processImageProxy(imageProxy: ImageProxy) {
        // Crop Image to square before processing further

        isProcessing = true
        try {
            // Get the current time
            val currentTime = System.currentTimeMillis()
            // Check if 350 milliseconds have passed since the last processing
            if (currentTime - lastProcessedTime >= 200) {
                // เริ่มจับเวลาทดสอบการประมวลผล
//                val startTime = System.currentTimeMillis()
                lastProcessedTime = currentTime
                // Convert YUV to Bitmap
                val bitmap = imageProxy.toBitmap()
                // Rotate ภาพ
                val rotatedBitmap = rotateBitmap(bitmap, 90f)

                // ตัดภาพตามสัดส่วนบัตรเครดิต
                val croppedBitmap = cropToCreditCardAspectRatio(rotatedBitmap)
                // แก้ให้ไม่ต้องแปลงเป็น ByteArray แต่ให้เป็น Bitmap เลย
                val outputBuffer = predictClasss(croppedBitmap)

                if (outputBuffer != null) {
                    val outputArray = outputBuffer.floatArray
                    // println(outputArray)
                    val maxIndex = outputArray.indices.maxByOrNull { outputArray[it] } ?: -1

                    // จัดการวัดค่า brightness และ Glare
                    val matrix =  bitmapToMat(croppedBitmap)
                    val brightness = calculateBrightness(matrix)
                    val glare = calculateGlare(matrix)

                    // อัพเดทค่าบน UI
                    cameraViewModel.updateBrightnessValueText(brightness.toString())
                    cameraViewModel.updateGlareValueText(glare.toString())

                    // 0 ต้องเท่ากับ บัตรปกติ
                    if (maxIndex == 0) {
                        isFound = if (glare >= 10000){
                            cameraViewModel.updateGuideText("หลีกเลี่ยงแสงสะท้อน")
                            false
                        }else{
                            cameraViewModel.updateGuideText("ถือค้างไว้")
                            true
                        }
                        
                    // 1 = บัตรสว่างเกินไป
                    } else if(maxIndex == 1) {
                        cameraViewModel.updateGuideText("กรุณาวางบัตรในกรอบ")
//                        foundCardTimer = 0
                        isFound = false
                    }

//                    else{
//                        isFound = false
//                    }
//                    val endTime = System.currentTimeMillis()
//                    val elapsedTime = endTime - startTime
                    // พิมพ์เวลาที่ใช้ในการประมวลผล
//                    println("Processing time: $elapsedTime ms")

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

    private fun predictClasss(imageBytes: Bitmap): TensorBuffer? {
        try {
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

    private fun bitmapToMat(bitmap: Bitmap): Mat {
        val mat = Mat() // Create an empty Mat
        Utils.bitmapToMat(bitmap, mat) // Convert Bitmap to Mat
        return mat
    }

    private fun calculateBrightness(mat: Mat): Double {
        val gray = Mat()
        Imgproc.cvtColor(mat, gray, Imgproc.COLOR_BGR2GRAY)
        val mean = Core.mean(gray)
        gray.release()
        return mean.`val`[0]
    }

    private fun calculateGlare(mat: Mat): Double {
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

            Text(
                text = "BrightnessValue ${cameraViewModel.brightnessValueText}",
                color = Color.White,
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.align(Alignment.BottomCenter)
            )


            Text(
                text = "GlareValue ${cameraViewModel.glareValueText}",
                color = Color.White,
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(20.dp) // Add 20dp padding
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
