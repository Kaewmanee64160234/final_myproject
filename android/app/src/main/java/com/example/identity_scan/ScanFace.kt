package com.example.identity_scan

import android.Manifest
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Matrix
import android.os.Build
import android.os.Bundle
import android.os.CountDownTimer
import android.util.Log
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentHeight
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
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.tensorflow.lite.DataType
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.io.File
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.LocalLifecycleOwner
import io.flutter.embedding.engine.dart.DartExecutor
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ButtonDefaults
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.googlefonts.Font
import androidx.compose.ui.text.googlefonts.GoogleFont
import androidx.compose.ui.text.style.TextAlign
import com.example.identity_scan.ml.ModelFace
import org.opencv.android.Utils
import org.opencv.core.Core
import org.opencv.core.Mat
import org.opencv.core.MatOfDouble
import org.opencv.core.MatOfPoint
import org.opencv.imgproc.Imgproc
import java.io.FileOutputStream
import java.io.OutputStream

class ScanFace : AppCompatActivity() {
    private lateinit var cameraExecutor: ExecutorService
    private val CAMERA_REQUEST_CODE = 2001
    private val cameraViewModel: CameraViewModel by viewModels()
    private lateinit var model: ModelFace
    private var isProcessing = false
    private var isPredicting = true
    private var lastProcessedTime: Long = 0
    private var isFound = false
    private lateinit var flutterEngine: FlutterEngine
    private lateinit var methodChannel: MethodChannel
    private val CHANNEL = "camera"
    private var isTiming = false
    // นับภาพที่ Capture จาก 1
    // จัดเก็บ Bitmap ของรูปภาพทั้ง 5
    private val bitmapList: MutableList<Bitmap> = mutableListOf()
    private var sharPestImageIndex = 0
    private lateinit var mat: Mat
    private var pathFinal = ""
    private lateinit var fontKanit : FontFamily

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        cameraExecutor = Executors.newSingleThreadExecutor()
        checkPermissions()
        checkAndRequestCameraPermission()
        model = ModelFace.newInstance(this)

        if (!org.opencv.android.OpenCVLoader.initDebug()) {
            Log.e("OpenCV", "OpenCV initialization failed")
        } else {
            Log.d("OpenCV", "OpenCV initialization successful")
        }

        val provider = GoogleFont.Provider(
            providerAuthority = "com.google.android.gms.fonts",
            providerPackage = "com.google.android.gms",
            certificates = R.array.com_google_android_gms_fonts_certs
        )

        val fontName = GoogleFont("Kanit")

        fontKanit = FontFamily(
            Font(
                googleFont = fontName,
                fontProvider = provider,
                weight = FontWeight.Bold,
            )
        )

        // Initialize FlutterEngine manually
        flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        methodChannel = MethodChannel(flutterEngine.dartExecutor, CHANNEL)

        setContent {
            Surface(
                modifier = Modifier.fillMaxSize(),
                color = Color.Black
            ) {
                Column(modifier = Modifier.fillMaxSize()) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.Center
                    ) {
                        Text(
                            fontFamily = fontKanit,
                            modifier = Modifier
                                .height(80.dp)
                                .padding(top = 40.dp),
                            text = "ถ่ายภาพใบหน้า",
                            color = Color.White,
                            style = TextStyle(fontSize = 20.sp, fontWeight = FontWeight.Bold)
                        )
                    }

                    // Camera with overlay and dynamic behavior
                    CameraWithOverlay(
                        modifier = Modifier.weight(1f),
                        guideText = cameraViewModel.guideText
                    )

                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(100.dp),
                        horizontalArrangement = Arrangement.Center,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Button(
                            onClick = {
                                val resultIntent = Intent()
                                setResult(RESULT_CANCELED, resultIntent)
                                finish()
                            },
                            colors = ButtonDefaults.buttonColors(Color.Red)
                        ) {
                            Text(
                                fontFamily = fontKanit,
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

    override fun onDestroy() {
        super.onDestroy()
        cameraExecutor.shutdown()

        // ปลด ModelDetectCard
        model.close()

        // ปลด FlutterEngine
        flutterEngine.destroy()
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

    @Composable
    fun CameraPreview(modifier: Modifier = Modifier) {
        var bitmapToShow by remember { mutableStateOf<Bitmap?>(null) }
        var isShutter by remember { mutableStateOf(false) }
        var showDialog by remember { mutableStateOf(false) }

        val context = LocalContext.current
        val lifecycleOwner = LocalLifecycleOwner.current

        val timer = object : CountDownTimer(1000, 800) {
            override fun onTick(millisUntilFinished: Long) {
                println("Time remaining: ${millisUntilFinished / 800} seconds")
            }
            override fun onFinish() {
                println("Founded For 1S")
                isShutter = true
            }
        }

            AndroidView(
                factory = { ctx ->
                    val previewView = PreviewView(ctx)
                    val cameraProviderFuture = ProcessCameraProvider.getInstance(ctx)

                    cameraProviderFuture.addListener({
                        val cameraProvider = cameraProviderFuture.get()

                        val preview = Preview.Builder()
                            .build()

                        val imageAnalysis = ImageAnalysis.Builder()
                            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                            .build()

                        imageAnalysis.setAnalyzer(Executors.newSingleThreadExecutor()) { imageProxy ->
                            // ถ้ามีคำสั่งให้ถ่ายรูป ค่าเริ่มต้นปกติคือ false ดังนั้นโปรแกรมจะวิ่งไปที่ Else ก่อนเสมอ
                            if (isShutter) {
                                bitmapToShow = imageProxy.toBitmap()

                                val matrix = Matrix()

                                // Rotate the bitmap counterclockwise by 90 degrees
                                matrix.postRotate(-90f)

                                // Apply the rotation to the bitmap
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

                                        // พักการ Predict
                                        isPredicting = false

                                        // รับ bitmap ภาพที่คมที่สุดเพื่อมา Process
                                        val sharpestBitmapMat = bitmapToMat(bitmapList[sharPestImageIndex])

                                        // บันทึกรูป Original ลง Storage
                                        saveMatToStorage(context,sharpestBitmapMat,"faceImage")
                                    }
                                }
                            }else if(!isShutter){
                                // ถ้ามีการสั่งให้จำแนก Class
                                if(isPredicting){
                                    // ประมวลภาพถ้ามีการสั่งให้ Predict
                                    processImageProxy(imageProxy)
                                    // ถ้าเจอ เริ่มจับเวลา
                                    if(isFound){
                                        if (!isTiming){
                                            isTiming = true
                                            timer.start()
                                            println("Start Timer")
                                        }
                                    }else{
                                        // ถ้าไม่เจอ ยกเลิกการจับเวลา
                                        timer.cancel()
                                        isTiming = false
                                    }
                                }
                            }
                            imageProxy.close()
                        }

                        val cameraSelector = CameraSelector.DEFAULT_FRONT_CAMERA

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

        // Show Dialog
        if (showDialog && bitmapToShow != null) {

            ShowImageDialog(
                bitmap =  bitmapToShow!!,
                onRetake = {
                    showDialog = false
                    // Clear Bitmap List หลังจากปิด Dialog
                    bitmapList.clear()
                    // กลับมา Predict หลังจากปิด Dialog
                    isPredicting = true
                    //รีเซ็ต GuideText เมื่อปิด Dialog (ถ่ายใหม่)
                    cameraViewModel.updateGuideText("ปรับหน้าให้อยู่ตรงกลาง")
                    isFound = false
                },
                onConfirm = {
                    val resultIntent = Intent()
                    if (pathFinal.isNotEmpty()) {
                        resultIntent.putExtra("result", pathFinal.toString())
                        setResult(RESULT_OK, resultIntent)
                        Log.w("pathFinal", pathFinal.toString())
                        finish()
                    }

                })
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
    fun ShowImageDialog(
        bitmap: Bitmap,
        onRetake: () -> Unit, // Callback for "ถ่ายใหม่"
        onConfirm: () -> Unit // Callback for "ยืนยัน"
    ) {
        Dialog(onDismissRequest = { /* Prevent dismiss by clicking outside */ }) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black.copy(alpha = 0.8f)) // Dim background
                    .padding(8.dp),
                contentAlignment = Alignment.Center
            ) {
                Surface(
                    modifier = Modifier

                        .wrapContentHeight()
                        .padding(8.dp),
                    shape = RoundedCornerShape(16.dp), // Rounded corners for a modern look
                    color = Color.White, // Dialog background
                    shadowElevation = 12.dp // Subtle shadow for emphasis
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(8.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        // Title Text
                        Text(
                            fontFamily = fontKanit,
                            text = "ยืนยันข้อมูล",
                            color = Color(0xFF2D3892), // Stylish blue title
                            fontSize = 22.sp, // Larger font size for prominence
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(bottom = 8.dp)
                        )

                        // Subtitle
                        Text(
                            fontFamily = fontKanit,
                            text = "กรุณาตรวจสอบความชัดเจนของภาพบัตร",
                            color = Color.Gray,
                            fontSize = 14.sp,
                            textAlign = TextAlign.Center,
                            modifier = Modifier.padding(bottom = 16.dp)
                        )

                        // Display the captured image
                        Image(
                            bitmap = bitmap.asImageBitmap(),
                            contentDescription = "Captured Image",
                            modifier = Modifier
                                .fillMaxWidth() // Wider image
                                .height(300.dp) // Adjusted height for layout
                                .clip(RoundedCornerShape(12.dp)) // Rounded corners for the image
                                .padding(8.dp) // Padding around the image
                        )

                        Spacer(modifier = Modifier.height(16.dp))

                        // Button row
                        Row(
                            modifier = Modifier
                                .fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceEvenly // Evenly distribute buttons
                        ) {
                            // Retake Button
                            Button(
                                onClick = onRetake,
                                colors = ButtonDefaults.buttonColors(containerColor = Color.White),
                                modifier = Modifier
                                    .weight(1f)
                                    .height(48.dp)
                                    .border(2.dp, Color.Gray, RoundedCornerShape(24.dp))
                            ) {
                                Text(
                                    fontFamily = fontKanit,
                                    text = "ถ่ายใหม่",
                                    color = Color.Black,
                                    fontSize = 16.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }

                            Spacer(modifier = Modifier.width(16.dp))

                            // Confirm Button
                            Button(
                                onClick = onConfirm,
                                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF2D3892)),
                                modifier = Modifier
                                    .weight(1f)
                                    .height(48.dp)
                                    .border(2.dp, Color(0xFF2D3892), RoundedCornerShape(24.dp)) // Border matches button color
                            ) {
                                Text(
                                    fontFamily = fontKanit,
                                    text = "ยืนยัน",
                                    color = Color.White,
                                    fontSize = 16.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                    }
                }
            }
        }
    }


    private fun processImageProxy(imageProxy: ImageProxy) {
        // Crop Image to square before processing further

        isProcessing = true
        try {
            // Get the current time
            val currentTime = System.currentTimeMillis()
            if (currentTime - lastProcessedTime >= 200) {
                lastProcessedTime = currentTime
                // Convert YUV to Bitmap
                val bitmap = imageProxy.toBitmap()

                // หมุน Bitmap
                val rotatedBitmap = rotateBitmap(bitmap, -90f)

                // Crop ให้เล็กลง
                val croppedBitmap =  cropToSquare(rotatedBitmap)

                // ตัดภาพตามสัดส่วนบัตรเครดิต
//                val croppedBitmap = cropToCreditCardAspectRatio(rotatedBitmap)
                val outputBuffer = predictClasss(croppedBitmap)

                if (outputBuffer != null) {
                    val outputArray = outputBuffer.floatArray
                    val maxIndex = outputArray.indices
                        .filter { outputArray[it] >= 0.7 } // เลือก index ที่ค่า >= 80
                        .maxByOrNull { outputArray[it] } ?: 4 // หากไม่มี index ที่เข้าเงื่อนไข ให้ใช้ค่า default เป็น 4

                    println(outputArray.joinToString(", ", prefix = "[", postfix = "]"))

//                    val maxIndex = outputArray.indices.maxByOrNull { outputArray[it] } ?: -1

                    // จัดการวัดค่า brightness และ Glare
                    mat =  bitmapToMat(bitmap)
                    val brightness = calculateBrightness(mat)
                    val glare = calculateGlare(mat)
                    val snrValue = calculateSNR(mat)
                    // อัพเดทค่าบน UI
                    cameraViewModel.updateBrightnessValueText(brightness.toString())
                    cameraViewModel.updateGlareValueText(glare.toString())
                    cameraViewModel.updateSnrValueText(snrValue.toString())

                    // 0 ต้องเท่ากับ บัตรปกติ
                    if (maxIndex == 0) {
                        isFound = true
                        cameraViewModel.updateGuideText("ถือค้างไว้")
                        // 1 = บัตรสว่างเกินไป
                    } else if(maxIndex == 1) {
                        cameraViewModel.updateGuideText("ปรับหน้าให้อยู่ตรงกลาง")
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
            // imageProxy.close()
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

    private fun cropToSquare(bitmap: Bitmap): Bitmap {
        // Get the bitmap's width and height
        val width = bitmap.width
        val height = bitmap.height

        // Calculate the side length of the square (the smaller of the width and height)
        val sideLength = minOf(width, height)

        // Center the square in the image
        val left = (width - sideLength) / 2
        val top = (height - sideLength) / 2

        // Crop the Bitmap into a square
        return Bitmap.createBitmap(
            bitmap,
            left,
            top,
            sideLength,
            sideLength
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

        // คำนวณพื้นที่รวมของภาพ
        val totalArea = mat.width() * mat.height()

        // คำนวณเปอร์เซ็นต์ของ Glare Area
        val glarePercentage = (glareArea / totalArea) * 100

        gray.release()
        binary.release()

        return glarePercentage
    }

    private fun calculateSNR(mat: Mat): Double {
        val grayMat = Mat()
        Imgproc.cvtColor(mat, grayMat, Imgproc.COLOR_BGR2GRAY)
        val meanStdDev = MatOfDouble()
        val stdDev = MatOfDouble()
        Core.meanStdDev(grayMat, meanStdDev, stdDev)
        grayMat.release()
        val mean = meanStdDev.toArray().firstOrNull() ?: 0.0
        val std = stdDev.toArray().firstOrNull() ?: 1.0 // Avoid division by zero
        return mean / std
    }

    private fun saveMatToStorage(context: Context, processedMat: Mat, fileName: String): Boolean {
        return try {
            // Step 1: Convert Mat to Bitmap
            val bitmap = Bitmap.createBitmap(processedMat.cols(), processedMat.rows(), Bitmap.Config.ARGB_8888)
            Utils.matToBitmap(processedMat, bitmap)

            // Step 2: Get app-specific storage directory
            val storageDir = File(context.getExternalFilesDir(null), "images")
            if (!storageDir.exists()) {
                if (storageDir.mkdirs()) {
                    println("Directory created successfully: ${storageDir.absolutePath}")
                } else {
                    println("Failed to create directory: ${storageDir.absolutePath}")
                    return false // Exit if folder creation fails
                }
            }

            // Step 3: Create a file to save the image
            val file = File(storageDir, "$fileName.png")
            val outputStream = FileOutputStream(file)

            // Step 4: Compress the Bitmap and write to file
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)

            // Step 5: Close the stream and return success

            outputStream.flush()
            outputStream.close()
//            step 6 send dataa
            pathFinal = file.absolutePath

            println("Image saved successfully at: ${file.absolutePath}")
            true
        } catch (e: Exception) {
            e.printStackTrace()
            println("Failed to save image: ${e.message}")
            false
        }
    }

    @Composable
    fun CameraWithOverlay(modifier: Modifier = Modifier, guideText: String) {
        // Dynamic colors based on guideText
        val borderColor by animateColorAsState(
            targetValue = if (guideText == "ถือค้างไว้") Color.Green else Color.Red,
            animationSpec = tween(durationMillis = 500)
        )
        val textColor by animateColorAsState(
            targetValue = if (guideText == "ถือค้างไว้") Color.Green else Color.White,
            animationSpec = tween(durationMillis = 500)
        )

        Box(modifier = modifier.fillMaxSize()) {
            // Camera Preview
            CameraPreview(modifier = Modifier.fillMaxSize())

            // Overlay with oval and guide text
            Canvas(modifier = Modifier.fillMaxSize()) {
                val canvasWidth = size.width
                val canvasHeight = size.height

                val ovalWidth = canvasWidth * 0.7f
                val ovalHeight = canvasHeight * 0.5f
                val ovalLeft = (canvasWidth - ovalWidth) / 2
                val ovalTop = (canvasHeight - ovalHeight) / 2

                // Background outside the oval
                drawRect(
                    color = Color.Black.copy(alpha = 0.6f),
                    size = size
                )

                // Clear the oval area
                drawOval(
                    color = Color.Transparent,
                    topLeft = Offset(ovalLeft, ovalTop),
                    size = Size(ovalWidth, ovalHeight),
                    blendMode =  BlendMode.Clear
                )

                // Oval border
                drawOval(
                    color = borderColor,
                    topLeft = Offset(ovalLeft, ovalTop),
                    size = Size(ovalWidth, ovalHeight),
                    style = Stroke(width = 8.dp.toPx())
                )
            }

            // Guide Text
            Text(
                fontFamily = fontKanit,
                text = guideText,
                color = textColor,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .padding(top = 16.dp)
            )

            // Instruction Text
            Text(
                fontFamily = fontKanit,
                text = "ให้ใบหน้าอยู่ในกรอบที่กำหนด ไม่มีปิดตา จมูก ปาก และคาง",
                color = Color.White,
                fontSize = 16.sp,
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(bottom = 16.dp)
            )
        }
    }
}
