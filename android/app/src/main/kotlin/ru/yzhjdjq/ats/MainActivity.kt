package ru.yzhjdjq.ats

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import ru.yzhjdjq.ats.core_interface.*

class MainActivity : FlutterActivity() {
    private val mesh = MeshFactory.create()

    companion object {
        private val CHANNEL = "ru.yzhjdjq.ats.platform_methods"
        private const val TAG = "MainActivity"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        startMeshForegroundService()

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

    override fun onDestroy() {
        super.onDestroy()
        // Останавливаем сервис при закрытии приложения
        if (MeshFactory.hasImplementation()) {
            try {
                val serviceClass = Class.forName("ru.yzhjdjq.ats.core.mesh.MeshForegroundService")
                val intent = Intent(this, serviceClass).apply {
                    action = "STOP"
                }
                startService(intent)
                Log.d(TAG, "MeshForegroundService stop requested")
            } catch (e: ClassNotFoundException) {
                Log.d(TAG, "MeshForegroundService class not found")
            } catch (e: Exception) {
                Log.e(TAG, "Error stopping MeshForegroundService", e)
            }
        }
    }

    private fun startMeshForegroundService() {
        if (!MeshFactory.hasImplementation()) return

        try {
            val serviceClass = Class.forName("ru.yzhjdjq.ats.core.mesh.MeshForegroundService")
            val intent = Intent(this, serviceClass).apply {
                action = "START"
            }
            startForegroundService(intent)
            Log.d(TAG, "MeshForegroundService started")
        } catch (e: ClassNotFoundException) {
            Log.d(TAG, "MeshForegroundService class not found, core module unavailable")
        } catch (e: Exception) {
            Log.e(TAG, "Error starting MeshForegroundService", e)
        }
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