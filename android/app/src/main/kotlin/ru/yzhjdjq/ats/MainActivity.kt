package ru.yzhjdjq.ats

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import ru.yzhjdjq.ats.core_interface.*

class MainActivity : FlutterActivity() {
    private val mesh = MeshFactory.create()
    private val CHANNEL = "ru.yzhjdjq.ats.platform_methods"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        flutterEngine?.dartExecutor?.binaryMessenger?.let { MethodChannel(it, CHANNEL) }
            ?.setMethodCallHandler { call, result ->
                when (call.method) {
                    "isImplemented" -> result.success(mesh.isImplemented())
                    "getPermissionsState" -> result.success((getPermissionsState(mesh.getPermissionsState())))
                    "sendMessage" -> result.success(sendMessage())
                    else -> result.notImplemented()
                }
            }
    }

    init {
        Log.d("MainActivity", sendMessage())
    }

    fun getPermissionsState(permissions: List<PermissionStatus>): Map<String, Map<String, Boolean>> {
        return permissions.map { permission ->
            permission.name.toChannelValue() to mapOf(
                "granted" to permission.granted,
                "required" to permission.required
            )
        }.toMap()
    }

    fun sendMessage(): String {
        return mesh.sendMessage().toChannelValue()
    }
}