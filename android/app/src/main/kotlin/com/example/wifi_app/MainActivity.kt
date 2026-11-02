package com.example.wifi_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private var networkPlugin: NetworkPlugin? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        networkPlugin = NetworkPlugin(
            applicationContext,
            flutterEngine.dartExecutor.binaryMessenger,
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        networkPlugin?.dispose()
        networkPlugin = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
