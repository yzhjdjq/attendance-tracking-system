package ru.yzhjdjq.ats

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import ru.yzhjdjq.ats.core_interface.MeshFactory
import ru.yzhjdjq.ats.utils.ChannelBridge

class MainActivity : FlutterActivity() {

  private val mesh = MeshFactory.create()

  companion object {
    private const val CHANNEL_METHODS = "ru.yzhjdjq.ats.platform_methods"
    private const val CHANNEL_METHODS_SERVICE_STATE = "ru.yzhjdjq.ats.platform_methods/service_state"
    private const val CHANNEL_EVENT_RECEIVE_MESSAGE = "ru.yzhjdjq.ats.platform_events/receive_message"
    private const val CHANNEL_EVENT_SERVICE_STATE = "ru.yzhjdjq.ats.platform_events/service_state"
    private const val CHANNEL_EVENT_NEIGHBORING_MEMBERS = "ru.yzhjdjq.ats.platform_events/neighboring_members"
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

  private val neighboringMembersBridge by lazy {
    ChannelBridge(
      scope = bridgeScope,
      flow = mesh.neighboringNetworkMembersFlow(),
    )
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    val messenger = flutterEngine?.dartExecutor?.binaryMessenger ?: return

    MethodChannel(messenger, CHANNEL_METHODS_SERVICE_STATE)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "isImplemented" -> result.success(mesh.isImplemented())
          "initMeshForegroundService" -> {
            mesh.initMeshForegroundService(applicationContext, call.arguments as String)
            result.success(null)
          }

          "isMeshForegroundServiceRunning" ->
            result.success(mesh.isMeshForegroundServiceRunning())

          "setUserId" -> {
            mesh.setUserId(applicationContext, call.arguments as String?)
            result.success(null)
          }

          else -> result.notImplemented()
        }
      }

    MethodChannel(messenger, CHANNEL_METHODS)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "getNumberOfNeighboringNetworkMembers" ->
            result.success(mesh.getNumberOfNeighboringNetworkMembers())

          "sendMessage" -> {
            @Suppress("UNCHECKED_CAST")
            val map = call.arguments as? Map<String, Any?>
            if (map == null) {
              result.error("BAD_ARGS", "Expected Map for sendMessage", null)
            } else {
              result.success(mesh.sendMessage(map).toChannelValue())
            }
          }

          else -> result.notImplemented()
        }
      }

    EventChannel(messenger, CHANNEL_EVENT_SERVICE_STATE)
      .setStreamHandler(object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
          serviceStateBridge.attach(events)
        }

        override fun onCancel(arguments: Any?) {
          serviceStateBridge.detach()
        }
      })

    EventChannel(messenger, CHANNEL_EVENT_RECEIVE_MESSAGE)
      .setStreamHandler(object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
          receiveMessageBridge.attach(events)
        }

        override fun onCancel(arguments: Any?) {
          receiveMessageBridge.detach()
        }
      })

    EventChannel(messenger, CHANNEL_EVENT_NEIGHBORING_MEMBERS)
      .setStreamHandler(object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
          neighboringMembersBridge.attach(events)
        }

        override fun onCancel(arguments: Any?) {
          neighboringMembersBridge.detach()
        }
      })
  }

  override fun onDestroy() {
    if (!isChangingConfigurations) {
      bridgeScope.cancel()
    }
    super.onDestroy()
  }
}
