package ru.yzhjdjq.ats

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import ru.yzhjdjq.ats.core_interface.*

class MainActivity : FlutterActivity() {
    private val mesh = MeshFactory.create()
    private var eventSink: EventChannel.EventSink? = null

    companion object {
        private const val CHANNEL_METHODS = "ru.yzhjdjq.ats.platform_methods"
        private const val CHANNEL_METHODS_INIT = "ru.yzhjdjq.ats.platform_methods/init"
        private const val CHANNEL_EVENT_RECEIVE_MESSAGE = "ru.yzhjdjq.ats.platform_events/receive_message"
        private const val TAG = "MainActivity"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        flutterEngine?.dartExecutor?.binaryMessenger?.let { MethodChannel(it, CHANNEL_METHODS_INIT) }
            ?.setMethodCallHandler { call, result ->
                when (call.method) {
                    "init" -> {
                        startMeshForegroundService(call.arguments as String)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        flutterEngine?.dartExecutor?.binaryMessenger?.let { MethodChannel(it, CHANNEL_METHODS) }
            ?.setMethodCallHandler { call, result ->
                when (call.method) {
                    "isImplemented" -> result.success(mesh.isImplemented())
                    "setUserId" -> {
                        mesh.setUserId(call.arguments as String)
                        result.success(null)
                    }
                    "getPermissionsState" -> result.success((getPermissionsState(mesh.getPermissionsState())))
                    "getNumberOfNetworkMembers" -> result.success(mesh.getNumberOfNetworkMembers())
                    "sendMessage" -> result.success(sendMessage(call.arguments as String))
                    else -> result.notImplemented()
                }
            }

        flutterEngine?.dartExecutor?.binaryMessenger?.let { EventChannel(it, CHANNEL_EVENT_RECEIVE_MESSAGE) }
            ?.setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    eventSink = events
                    CoroutineScope(Dispatchers.IO).launch {
                        mesh.setCallbackReceiveMessage { message ->
                            runOnUiThread {
                                eventSink?.success(message)
                            }
                        }
                    }
                }
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
    }

    override fun onDestroy() {
        super.onDestroy()
        if (MeshFactory.hasImplementation()) {
            try {
                val serviceClass = Class.forName("ru.yzhjdjq.ats.core.mesh.MeshForegroundService")
                val intent = Intent(this, serviceClass).apply {
                    action = "STOP"
                }
                startService(intent)
                Log.d(TAG, "MeshForegroundService stop requested")
            } catch (_: ClassNotFoundException) {
                Log.d(TAG, "MeshForegroundService class not found")
            } catch (e: Exception) {
                Log.e(TAG, "Error stopping MeshForegroundService", e)
            }
        }
    }

    private fun startMeshForegroundService(userId: String) {
        if (!MeshFactory.hasImplementation()) return

        try {
            val serviceClass = Class.forName("ru.yzhjdjq.ats.core.mesh.MeshForegroundService")
            val intent = Intent(this, serviceClass).apply {
                action = "START"
                putExtra("EXTRA_USER_ID", userId)
            }
            startForegroundService(intent)
            Log.d(TAG, "MeshForegroundService started via reflection")
        } catch (_: ClassNotFoundException) {
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

    fun sendMessage(message: String): String {
        return mesh.sendMessage(message).toChannelValue()
    }
}