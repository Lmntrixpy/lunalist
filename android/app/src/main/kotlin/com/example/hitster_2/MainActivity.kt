package com.example.hitster_2

import android.content.Context
import android.media.AudioManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "audio_status"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "isMusicActive") {
                    val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                    val isActive = audioManager.isMusicActive
                    result.success(isActive)
                } else {
                    result.notImplemented()
                }
            }
    }
}
