package ru.yzhjdjq.ats

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import ru.yzhjdjq.ats.core_interface.*
import ru.yzhjdjq.ats.utils.ChannelBridge

class MainActivity : FlutterActivity() {
    private val mesh = MeshFactory.create()

    companion object {
        private const val CHANNEL_METHODS = "ru.yzhjdjq.ats.platform_methods"
        private const val CHANNEL_METHODS_SERVICE_STATE = "ru.yzhjdjq.ats.platform_methods/service_state"
        private const val CHANNEL_EVENT_RECEIVE_MESSAGE = "ru.yzhjdjq.ats.platform_events/receive_message"
        private const val CHANNEL_EVENT_SERVICE_STATE = "ru.yzhjdjq.ats.platform_events/service_state"
    }

    private val bridgeScope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    private val serviceStateBridge by lazy {
        ChannelBridge(
            scope = bridgeScope,
            flow = mesh.serviceStateFlow(),
            initialValue = { mesh.isMeshForegroundServiceRunning() },
        )
    }

    private val receiveMessageBridge by lazy {
        ChannelBridge(
            scope = bridgeScope,
            flow = mesh.receiveMessageFlow(),
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        flutterEngine?.dartExecutor?.binaryMessenger?.let { MethodChannel(it, CHANNEL_METHODS_SERVICE_STATE) }
            ?.setMethodCallHandler { call, result ->
                when (call.method) {
                    "isImplemented" -> result.success(mesh.isImplemented())
                    "initMeshForegroundService" -> {
                        mesh.initMeshForegroundService(applicationContext, call.arguments as String)
                        result.success(null)
                    }
                    "isMeshForegroundServiceRunning" -> result.success(mesh.isMeshForegroundServiceRunning())
                    "setUserId" -> {
                        mesh.setUserId(applicationContext, call.arguments as String?)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        flutterEngine?.dartExecutor?.binaryMessenger?.let { MethodChannel(it, CHANNEL_METHODS) }
            ?.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getNumberOfNetworkMembers" -> result.success(mesh.getNumberOfNetworkMembers())
                    "sendMessage" -> result.success(mesh.sendMessage(call.arguments as String).toChannelValue())
                    else -> result.notImplemented()
                }
            }

        flutterEngine?.dartExecutor?.binaryMessenger?.let { EventChannel(it, CHANNEL_EVENT_SERVICE_STATE) }
            ?.setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    serviceStateBridge.attach(events)
                }
                override fun onCancel(arguments: Any?) {
                    serviceStateBridge.detach()
                }
            })

        flutterEngine?.dartExecutor?.binaryMessenger?.let { EventChannel(it, CHANNEL_EVENT_RECEIVE_MESSAGE) }
            ?.setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    receiveMessageBridge.attach(events)
                }
                override fun onCancel(arguments: Any?) {
                    receiveMessageBridge.detach()
                }
            })
    }

    override fun onDestroy() {
        if(!isChangingConfigurations)
            bridgeScope.cancel()

        super.onDestroy()
    }
}
