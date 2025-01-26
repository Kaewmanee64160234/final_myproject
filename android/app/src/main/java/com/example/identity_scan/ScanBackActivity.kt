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
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.core.resolutionselector.ResolutionStrategy
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.LinearOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
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
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.foundation.shape.RoundedCornerShape
import com.example.identity_scan.ml.ModelUnquant
import org.opencv.android.Utils
import org.opencv.core.Core
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.MatOfDouble
import org.opencv.core.MatOfPoint
import org.opencv.imgproc.Imgproc
import java.io.FileOutputStream
import java.io.OutputStream
import kotlin.math.pow
import androidx.compose.material3.ButtonDefaults
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.googlefonts.Font
import androidx.compose.ui.text.googlefonts.GoogleFont
import androidx.compose.ui.text.style.TextAlign
import org.opencv.imgcodecs.Imgcodecs


class ScanBackActivity: AppCompatActivity() {
    private lateinit var cameraExecutor: ExecutorService
    private val CAMERA_REQUEST_CODE = 2001
    private val cameraViewModel: CameraViewModel by viewModels()
    private val rectPositionViewModel: RectPositionViewModel by viewModels()
    private var isPredicting = true
    private lateinit var model: ModelUnquant
    private var isProcessing = false
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

        model = ModelUnquant.newInstance(this)

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
            var showDialog by remember { mutableStateOf(false) }
            BackHandler {
                showDialog = true
            }

            Surface(
                modifier = Modifier.fillMaxSize(),
                color = Color.Black // Set background color to black
            ) {
                Box(modifier = Modifier.fillMaxSize()) {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(16.dp), // Add padding for consistent layout
                        verticalArrangement = Arrangement.SpaceBetween, // Space out elements vertically
                        horizontalAlignment = Alignment.CenterHorizontally // Center elements horizontally
                    ) {
                        // Title
                        Text(
                            text = "สแกนหลังบัตร",
                            color = Color.White,
                            style = TextStyle(fontSize = 20.sp, fontWeight = FontWeight.Bold),
                            textAlign = TextAlign.Center,
                            modifier = Modifier
                                .padding(bottom = 16.dp) // Adjust padding below the title
                                .wrapContentWidth() // Ensure text wraps naturally
                        )

                        // Camera preview with overlay
                        CameraWithOverlay(
                            modifier = Modifier.weight(1f), // Take up available space
                            cameraViewModel = cameraViewModel,
                            rectPositionViewModel = rectPositionViewModel
                        )
                        if (showDialog) {
                            ShowCancelConfirmationDialog(
                                onConfirm = {
                                    // Perform the action on confirmation (e.g., navigate back)
                                    showDialog = false
                                    // Add your navigation logic here
                                   cancelProcess()
                                },
                                onDismiss = {
                                    // Close the dialog
                                    showDialog = false
                                }
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
    fun CameraWithOverlay(
        modifier: Modifier = Modifier,
        cameraViewModel: CameraViewModel,
        rectPositionViewModel: RectPositionViewModel
    ) {
        // Animation states
        val selectedSize = remember { mutableStateOf(0.8f) } // Default rectangle size
        val animatedRectWidth = animateFloatAsState(
            targetValue = selectedSize.value,
            animationSpec = tween(durationMillis = 500, easing = LinearOutSlowInEasing)
        )

        val pulseScale = rememberInfiniteTransition().animateFloat(
            initialValue = 1f,
            targetValue = 1.1f,
            animationSpec = infiniteRepeatable(
                animation = tween(1000, easing = FastOutSlowInEasing),
                repeatMode = RepeatMode.Reverse
            )
        )

        Box(
            modifier = modifier
                .fillMaxSize()
                .background(Color.Black)
        ) {
            // Camera preview centered
            Box(
                modifier = Modifier
                    .align(Alignment.Center) // Center the preview
                    .fillMaxSize()
            ) {
                CameraPreview(modifier = Modifier.fillMaxSize())
            }

            Canvas(modifier = Modifier.fillMaxSize()) {
                val creditCardAspectRatio = 3.37f / 2.125f
                val rectWidth = size.width * animatedRectWidth.value * pulseScale.value
                val rectHeight = rectWidth / creditCardAspectRatio
                val rectLeft = (size.width - rectWidth) / 2
                val rectTop = (size.height - rectHeight) / 2
                val cornerRadius = 20.dp.toPx()

                drawRect(
                    color = Color.Black.copy(alpha = 0.6f),
                    size = size
                )
                drawRoundRect(
                    color = Color.Transparent,
                    topLeft = Offset(rectLeft, rectTop),
                    size = Size(rectWidth, rectHeight),
                    cornerRadius = CornerRadius(cornerRadius, cornerRadius),
                    blendMode = BlendMode.Clear
                )

                drawRoundRect(
                    color = Color.Gray,
                    topLeft = Offset(rectLeft, rectTop),
                    size = Size(rectWidth, rectHeight),
                    cornerRadius = CornerRadius(cornerRadius, cornerRadius),
                    style = Stroke(width = 6f)
                )

                rectPositionViewModel.updateRectPosition(
                    left = rectLeft,
                    top = rectTop,
                    right = rectLeft + rectWidth,
                    bottom = rectTop + rectHeight
                )
            }

            // Guide Text
            Text(
                fontFamily = fontKanit,
                text = cameraViewModel.guideText,
                color = Color.White,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .padding(top = 80.dp)
            )

            // Instruction Text
            Text(
                fontFamily = fontKanit,
                text = "ไม่วางนิ้วมือบดบังรูป ตัวอักษร หรือสัญลักษณ์บนหน้าบัตร",
                color = Color.White,
                fontSize = 16.sp,
                textAlign = TextAlign.Center, // จัดข้อความให้อยู่กึ่งกลาง
                modifier = Modifier
                    .fillMaxWidth() // ให้ข้อความยืดเต็มความกว้าง
                    .align(Alignment.BottomCenter) // จัดตำแหน่งให้อยู่ด้านล่างตรงกลาง
                    .padding(bottom = 16.dp) // เพิ่ม padding ด้านล่าง
            )

        }
    }

    @Composable
    fun CameraPreview(modifier: Modifier = Modifier) {
        var bitmapToShow by remember { mutableStateOf<Bitmap?>(null) }
        var isShutter by remember { mutableStateOf(false) }
        var showDialog by remember { mutableStateOf(false) }

        val context = LocalContext.current
        val lifecycleOwner = LocalLifecycleOwner.current

         val timer = object : CountDownTimer(1500, 800) {
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
                             if(isShutter){
                                 bitmapToShow = imageProxy.toBitmap()
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

                                 // ถ้าภาพยังไม่ครบ 3 ภาพ และ Dialog ไม่ได้แสดงอยู่
                                 if (bitmapList.size < 3){
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

                                         val contrastValue = calculateContrast(sharpestBitmapMat)
                                         val resolutionValue = calculateResolution(sharpestBitmapMat)
                                         val snrValue = calculateSNR(sharpestBitmapMat)

                                         val processedMat = preprocessing(snrValue, contrastValue, resolutionValue, sharpestBitmapMat)

                                         // บันทึกรูป Original ลง Storage
                                         saveMatToStorage(context,sharpestBitmapMat,"frontCardOriginal")

                                         // บันทึกลง Storage
                                         saveMatToStorage(context,processedMat,"frontCardProcessed")
                                     }
                                 }
                             }
                             else if(!isShutter){
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
                    cameraViewModel.updateGuideText("กรุณาวางบัตรในกรอบ")
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

    @Composable
    fun ShowCancelConfirmationDialog(
        onConfirm: () -> Unit,
        onDismiss: () -> Unit
    ) {
        androidx.compose.material.AlertDialog(
            onDismissRequest = { onDismiss() },
            title = {
                Text(
                    fontFamily = fontKanit,
                    text = "Confirmation",
                    style = androidx.compose.material.MaterialTheme.typography.h6
                )
            },
            text = {
                Text(
                    fontFamily = fontKanit,
                    text = "Are you sure you want to cancel and go back?",
                    style = androidx.compose.material.MaterialTheme.typography.body2
                )
            },
            confirmButton = {
                Button(
                    onClick = { onConfirm() },
                    colors = ButtonDefaults.buttonColors()
                ) {
                    Text(
                        fontFamily = fontKanit,
                        text = "Yes", color = Color.White
                    )
                }
            },
            dismissButton = {
                Button(
                    onClick = { onDismiss() },
                    colors = ButtonDefaults.buttonColors()
                ) {
                    Text(
                        fontFamily = fontKanit,
                        text = "No", color = Color.White
                    )
                }
            },
            backgroundColor = Color.White,
            contentColor = Color.Black
        )
    }


    private fun cancelProcess(){
        val resultIntent = Intent()
        setResult(RESULT_CANCELED, resultIntent)
        finish() // Closes the current activity
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

                    print(outputArray)

                    // จัดการวัดค่า brightness และ Glare
                    mat =  bitmapToMat(croppedBitmap)
                    val brightness = calculateBrightness(mat)
                    val glare = calculateGlare(mat)
                    val snrValue = calculateSNR(mat)
                    // อัพเดทค่าบน UI
                    cameraViewModel.updateBrightnessValueText(brightness.toString())
                    cameraViewModel.updateGlareValueText(glare.toString())
                    cameraViewModel.updateSnrValueText(snrValue.toString())

                    // 0 ต้องเท่ากับ บัตรปกติ
                    if (maxIndex == 0 ) {
                        isFound = if (brightness < 120) {
                            cameraViewModel.updateGuideText("แสงน้อยเกินไป")
                            false // คืนค่า false หาก brightness < 120
                        } else if (glare > 1) {
                            cameraViewModel.updateGuideText("หลีกเลี่ยงแสงสะท้อน")
                            false // คืนค่า false หาก glare > 1
                        } else {
                            cameraViewModel.updateGuideText("ถือค้างไว้")
                            true // คืนค่า true หากไม่มีเงื่อนไขข้างต้น
                        }

                    // 1 = บัตรสว่างเกินไป
                    } else if(maxIndex == 4) {
                        cameraViewModel.updateGuideText("กรุณาใช้บัตรจริง")
                        isFound = false
                    } else if (maxIndex ==2){
                        cameraViewModel.updateGuideText("กรุณาเอามือออกจากบัตรประชาชน")
                        isFound = false
                    }else if(maxIndex == 1 ){
                        cameraViewModel.updateGuideText("กรุณาใช้หลังบัตร")
                    }else if(maxIndex == 3){
                        cameraViewModel.updateGuideText("ไม่พบบัตร")
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

        // คำนวณพื้นที่รวมของภาพ
        val totalArea = mat.width() * mat.height()

        // คำนวณเปอร์เซ็นต์ของ Glare Area
        val glarePercentage = (glareArea / totalArea) * 100

        gray.release()
        binary.release()

        return glarePercentage
    }

    // ฟังก์ชันหลักในการประมวลผลภาพ
    private fun preprocessing(snr: Double, contrast: Double, resolution: String, inputMat: Mat): Mat {
        val (width, height) = resolution.split("x").map { it.toInt() }
        val minResolution = 500 // Minimum acceptable resolution for OCR
        val snrThreshold = 10.0 // Minimum SNR threshold
        val contrastThreshold = 50.0 // Minimum contrast threshold

        if (width < minResolution || height < minResolution) {
            println("Image resolution is too low ($resolution). Skipping preprocessing.")
            return inputMat // Return the original image if resolution is insufficient
        }

        return if (snr < snrThreshold || contrast < contrastThreshold) {
            println("Image quality is medium (SNR: $snr, Contrast: $contrast). Applying preprocessing...")

            // Clone the original Mat to avoid modifying it directly
            var processedMat = inputMat.clone()

            // Ensure the input is in the correct color format
            if (processedMat.type() == CvType.CV_8UC4) {
                println("Converting from RGBA to BGR")
                Imgproc.cvtColor(processedMat, processedMat, Imgproc.COLOR_RGBA2BGR)
            } else if (processedMat.type() == CvType.CV_8UC1) {
                println("Grayscale image, no need to convert")
            } else {
                println("Unexpected Mat type: ${processedMat.type()}")
            }

            processedMat = applyGammaCorrection(processedMat, gamma = 1.8)

            processedMat = reduceNoiseWithBilateral(processedMat)

            processedMat = enhanceSharpenUnsharpMask(processedMat)

            if (processedMat.type() == CvType.CV_8UC3) {
                println("Converting from BGR to RGBA")
                Imgproc.cvtColor(processedMat, processedMat, Imgproc.COLOR_BGR2RGBA)
            }

            println("Preprocessing completed.")
            processedMat
        } else {
            println("Image quality is sufficient (SNR: $snr, Contrast: $contrast). Skipping preprocessing.")
            inputMat
        }
    }

    // Gamma Correction
    fun applyGammaCorrection(image: Mat, gamma: Double = 1.8): Mat {
        // Calculate the inverse of gamma
        val invGamma = 1.0 / gamma

        // Create a lookup table for gamma correction
        val lut = Mat(1, 256, CvType.CV_8U)
        for (i in 0..255) {
            lut.put(0, i, ((i / 255.0).toDouble().pow(invGamma) * 255).toInt().toDouble())
        }

        // Apply the gamma correction using LUT
        val correctedImage = Mat()
        Core.LUT(image, lut, correctedImage)

        // Return the corrected image
        return correctedImage
    }



    // Supporting preprocessing functions
    fun reduceNoiseWithBilateral(mat: Mat, d: Int = 9, sigmaColor: Double = 75.0, sigmaSpace: Double = 75.0): Mat {
        val output = Mat()
        Imgproc.bilateralFilter(mat, output, d, sigmaColor, sigmaSpace)
        return output
    }


    fun reduceNoiseWithMedian(mat: Mat, kernelSize: Int = 5): Mat {
        val output = Mat()
        Imgproc.medianBlur(mat, output, kernelSize)
        return output
    }

    fun enhanceSharpenUnsharpMask(mat: Mat, strength: Double = 1.5, blurKernel: org.opencv.core.Size = org.opencv.core.Size(
        5.0,
        5.0
    )
    ): Mat {
        val blurred = Mat()
        Imgproc.GaussianBlur(mat, blurred, blurKernel, 0.0)
        val sharpened = Mat()
        Core.addWeighted(mat, 1.0 + strength, blurred, -strength, 0.0, sharpened)
        return sharpened
    }

    private fun calculateContrast(mat: Mat): Double {
        val grayMat = Mat()
        Imgproc.cvtColor(mat, grayMat, Imgproc.COLOR_BGR2GRAY)
        val minMaxLoc = Core.minMaxLoc(grayMat)
        grayMat.release()
        return minMaxLoc.maxVal - minMaxLoc.minVal
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

    private fun calculateResolution(mat: Mat): String {
        return "${mat.cols()}x${mat.rows()}"
    }

    private fun saveMatToStorage(context: Context, processedMat: Mat, fileName: String): Boolean {
        val startTime = System.currentTimeMillis() // Capture start time

        return try {
            // Step 1: Convert BGR to RGB
            val rgbMat = Mat()
            Imgproc.cvtColor(processedMat, rgbMat, Imgproc.COLOR_BGR2RGB)

            // Step 2: Get app-specific storage directory
            val storageDir = File(context.getExternalFilesDir(null), "images")
            if (!storageDir.exists()) {
                if (!storageDir.mkdirs()) {
                    println("Failed to create directory: ${storageDir.absolutePath}")
                    return false
                }
            }

            // Step 3: Directly use OpenCV imwrite for fast saving
            val file = File(storageDir, "$fileName.jpg")
            val success = Imgcodecs.imwrite(file.absolutePath, rgbMat)

            if (!success) {
                println("Failed to save image using OpenCV imwrite")
                return false
            }

            // Step 4: Return success
            pathFinal = file.absolutePath
            println("Image saved successfully at: ${file.absolutePath}")

            val endTime = System.currentTimeMillis() // Capture end time
            val runtime = endTime - startTime // Calculate the difference
            println("Image saved in $runtime ms")

            true
        } catch (e: Exception) {
            e.printStackTrace()
            println("Failed to save image: ${e.message}")
            false
        }
    }
}
