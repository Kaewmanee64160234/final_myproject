package com.example.identity_scan

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.TextView

class ScanFrontActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Create a TextView and set some text
        val textView = TextView(this)
        textView.text = "Hello, Welcome to Scan Front Activity!"

        // Set the TextView as the content view of the activity
        setContentView(textView)
    }
}