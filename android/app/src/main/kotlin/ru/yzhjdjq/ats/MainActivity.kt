package ru.yzhjdjq.ats

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import ru.yzhjdjq.ats.core_interface.*

class MainActivity : FlutterActivity() {
    private val testInterface = TestInterfaceFactory.create()
    private val CHANNEL = "ru.yzhjdjq.ats.platform_methods"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        flutterEngine?.dartExecutor?.binaryMessenger?.let { MethodChannel(it, CHANNEL) }
            ?.setMethodCallHandler { call, result ->
                when (call.method) {
                    "performPlatformOperation" ->
                        result.success(performPlatformOperation())
                    else -> result.notImplemented()
                }
            }
    }

    init {
        Log.d("MainActivity", performPlatformOperation())
    }

    fun performPlatformOperation(): String {
        return testInterface.SendMessage().toString()
    }
}