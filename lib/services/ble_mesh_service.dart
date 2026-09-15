import 'package:flutter/foundation.dart'
    show kDebugMode, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/services.dart'
    show MethodChannel, PlatformException, MissingPluginException, EventChannel;

import 'package:ats/models/models.dart' show DeliveryStatus, Message;

class BleMeshService {
  static const platformMethods = MethodChannel(
    'ru.yzhjdjq.ats.platform_methods',
  );
  static const platformMethodsServiceState = MethodChannel(
    'ru.yzhjdjq.ats.platform_methods/service_state',
  );
  static const EventChannel _eventChannelReceiveMessage = EventChannel(
    'ru.yzhjdjq.ats.platform_events/receive_message',
  );
  static const EventChannel _eventChannelServiceState = EventChannel(
    'ru.yzhjdjq.ats.platform_events/service_state',
  );
  static Stream<Message>? _eventReceivedMessageStream;
  static Stream<bool>? _eventServiceStateStream;

  static Stream<Message> get receiveMessageEvents {
    return _eventReceivedMessageStream ??=
        _InvokePlatformMethods._receiveBroadcastStream<Map<dynamic, dynamic>>(
          _eventChannelReceiveMessage,
          'received messages',
        ).map((raw) => Message.fromMap(Map<String, dynamic>.from(raw)));
  }

  static Stream<bool> get serviceStateEvents {
    return _eventServiceStateStream ??=
        _InvokePlatformMethods._receiveBroadcastStream(
          _eventChannelServiceState,
          'service state changes',
        );
  }

  static Future<bool> isImplemented() async {
    return await _InvokePlatformMethods._invokeMethod<bool>(
          platformMethodsServiceState,
          'isImplemented',
          onDefaultErrorResult: () => false,
        ) ??
        false;
  }

  static Future<void> initMeshService(String userId) async {
    return await _InvokePlatformMethods._invokeMethod<void>(
      platformMethodsServiceState,
      'initMeshForegroundService',
      args: userId,
    );
  }

  static Future<bool> isMeshForegroundServiceRunning() async {
    return await _InvokePlatformMethods._invokeMethod<bool>(
          platformMethodsServiceState,
          'isMeshForegroundServiceRunning',
        ) ??
        false;
  }

  static Future<void> setUserId(String? userId) async {
    await _InvokePlatformMethods._invokeMethod<void>(
      platformMethodsServiceState,
      'setUserId',
      args: userId,
    );
  }

  static Future<int> getNumberOfNetworkMembers() async {
    return await _InvokePlatformMethods._invokeMethod<int>(
          platformMethods,
          'getNumberOfNetworkMembers',
          onDefaultErrorResult: () => 0,
        ) ??
        0;
  }

  static Future<DeliveryStatus> sendMessage(Message message) async {
    return DeliveryStatus.fromChannelValue(
      await _InvokePlatformMethods._invokeMethod<String?>(
            platformMethods,
            'sendMessage',
            args: message.toMap(),
            onDefaultErrorResult: () => DeliveryStatus.notImplemented.name,
          ) ??
          DeliveryStatus.notImplemented.name,
    );
  }
}

abstract final class _InvokePlatformMethods {
  static final bool _isAndroid =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<T?> _invokeMethod<T>(
    MethodChannel platformChannel,
    String method, {
    dynamic args,
    T Function(T? result)? onSuccess,
    T Function()? onDefaultErrorResult,
    T Function(PlatformException e)? onError,
    T Function(MissingPluginException e)? onMissingPlugin,
    T Function(Object e)? onUnknownError,
    T Function()? onPlatformMismatch,
  }) async {
    if (!_isAndroid) {
      if (kDebugMode) {
        print('Method "$method" skipped: Not Android platform');
      }
      return onPlatformMismatch?.call() ?? onDefaultErrorResult?.call();
    }

    try {
      final result = args != null
          ? await platformChannel.invokeMethod<T>(method, args)
          : await platformChannel.invokeMethod<T>(method);
      return onSuccess?.call(result) ?? result;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('PlatformException in $method: ${e.message}');
      }
      return onError?.call(e) ?? onDefaultErrorResult?.call();
    } on MissingPluginException catch (e) {
      if (kDebugMode) {
        print('MissingPluginException in $method: ${e.message}');
      }
      return onMissingPlugin?.call(e) ?? onDefaultErrorResult?.call();
    } catch (e) {
      if (kDebugMode) {
        print('Unknown error in $method: $e');
      }
      return onUnknownError?.call(e) ?? onDefaultErrorResult?.call();
    }
  }

  static Stream<T> _receiveBroadcastStream<T>(
    EventChannel eventChannel,
    String? eventName,
  ) {
    if (!_isAndroid) {
      if (kDebugMode) {
        print(
          'Subscription to listen ${eventName ?? 'event'} skipped: Not Android platform',
        );
      }
      return Stream<T>.empty();
    }

    return eventChannel.receiveBroadcastStream().cast<T>();
  }
}
