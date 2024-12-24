package com.example.identity_scan

// Animation
import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.tween
import androidx.compose.animation.slideInHorizontally
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.requiredSize
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.Icon
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.ThumbUp
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Button
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

class AnimaActivity : AppCompatActivity() {
        override fun onCreate(savedInstanceState: Bundle?) {
            super.onCreate(savedInstanceState)
            setContent {
                var isVisible by remember { mutableStateOf(false) }

                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = Color.White
                ) {
                    Column(
                        modifier = Modifier.fillMaxSize(),
                        verticalArrangement = Arrangement.Center,
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        // First Button
//                        Button(onClick = { finish() }) {
//                            Text("Toggle Animation")
//                        }


                        // AnimatedVisibility

                        Box(modifier = Modifier.requiredSize(48.dp).fillMaxWidth()) {
                            this@Column.AnimatedVisibility(
                                visible = isVisible,
                                enter = slideInHorizontally(animationSpec = tween(durationMillis = 300), initialOffsetX =  {-it})
                            ) {
                                
                                Icon(
                                    imageVector = Icons.Default.Warning,
                                    contentDescription = "Favorite",
                                    modifier = Modifier
                                        .size(48.dp)  // ขนาดของไอคอน
                                        .align(Alignment.Center)  // จัดกลางใน Box
                                )
                            }
                        }


                        Button(onClick = { isVisible = !isVisible }) {  // Toggle visibility on second button click
                            Text("Toggle")
                        }
                    }
                }
            }
        }

    @Composable
    fun MyToggleButton(
        checked: Boolean,
        onCheckedChange: (Boolean) -> Unit
    ) {
        Box(
            modifier = Modifier
                .size(24.dp)
                .clip(CircleShape)
                .background(if (checked) Color.Green else Color.Gray)
                .clickable { onCheckedChange(!checked) }
        )
    }
}
