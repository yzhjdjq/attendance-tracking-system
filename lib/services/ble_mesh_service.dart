import 'package:flutter/foundation.dart'
    show kDebugMode, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/services.dart'
    show MethodChannel, PlatformException, MissingPluginException, EventChannel;

import 'package:ats/models/models.dart' show Message;

enum Permissions {
  notImplemented,
  bluetooth,
  bluetoothAdmin,
  bluetoothScan,
  bluetoothConnect,
  bluetoothAdvertise,
  accessFineLocation,
  accessCoarseLocation,
  postNotifications;

  static Permissions fromChannelValue(String? value) {
    return value == null
        ? Permissions.notImplemented
        : Permissions.values.firstWhere(
            (e) => e.name.toLowerCase() == value.toLowerCase(),
            orElse: () => Permissions.notImplemented,
          );
  }
}

class PermissionInfo {
  final Permissions name;
  final bool granted;
  final bool required;

  PermissionInfo({
    required this.name,
    required this.granted,
    required this.required,
  });

  factory PermissionInfo.fromMap(String name, Map<dynamic, dynamic> map) {
    return PermissionInfo(
      name: Permissions.fromChannelValue(name),
      granted: map['granted'] ?? false,
      required: map['required'] ?? false,
    );
  }
}

enum SendResult {
  notImplemented,
  success,
  error;

  static SendResult fromChannelValue(String? value) {
    return value == null
        ? SendResult.error
        : SendResult.values.firstWhere(
            (e) => e.name.toLowerCase() == value.toLowerCase(),
            orElse: () => SendResult.error,
          );
  }
}

class BleMeshService {
  static const platformMethods = MethodChannel('ru.yzhjdjq.ats.platform_methods');
  static const platformMethodsServiceState = MethodChannel('ru.yzhjdjq.ats.platform_methods/service_state');
  static const EventChannel _eventChannelReceiveMessage = EventChannel('ru.yzhjdjq.ats.platform_events/receive_message');
  static const EventChannel _eventChannelServiceState = EventChannel('ru.yzhjdjq.ats.platform_events/service_state');
  static Stream<String>? _eventReceivedMessageStream;
  static Stream<bool>? _eventServiceStateStream;

  static Stream<String> get receiveMessageEvents {
    return _eventReceivedMessageStream ??= _InvokePlatformMethods._receiveBroadcastStream(_eventChannelReceiveMessage, 'received messages');
  }

  static Stream<bool> get serviceStateEvents {
    return _eventServiceStateStream ??= _InvokePlatformMethods._receiveBroadcastStream(_eventChannelServiceState, 'service state changes');
  }

  
  static Future<bool> isImplemented() async {
    return await _InvokePlatformMethods._invokeMethod<bool>(
      platformMethodsServiceState,
      'isImplemented',
      onDefaultErrorResult: () => false,
    ) ?? false;
  }

  static Future<void> initMeshService(String userId) async {
    return await _InvokePlatformMethods._invokeMethod<void>(
      platformMethodsServiceState,
      'initMeshForegroundService',
      args: userId,
      );
  }

  static Future<void> isMeshForegroundServiceRunning() async {
    return await _InvokePlatformMethods._invokeMethod<void>(
      platformMethodsServiceState,
      'isMeshForegroundServiceRunning',
      );
  }

  static Future<void> setUserId(String? userId) async {
    await _InvokePlatformMethods._invokeMethod<void>(
      platformMethodsServiceState,
      'setUserId',
      args: userId,
    );
  }

  static Future<List<PermissionInfo>> getPermissionsState() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final result = await platformMethods.invokeMethod<Map<dynamic, dynamic>>(
          'getPermissionsState',
        );
        if (result == null) {
          return [];
        }
        return result.entries.map((entry) {
          return PermissionInfo.fromMap(entry.key, entry.value);
        }).toList();
      } on PlatformException catch (e) {
        if (kDebugMode) {
          print("Ошибка при получении состояния разрешений: $e");
          return [];
        }
      } on MissingPluginException catch (e) {
        if (kDebugMode) {
          print("BLE Mesh ядро не реализовано: ${e.message}");
          return [];
        }
      } catch (e) {
        if (kDebugMode) {
          print("Неизвестная ошибка при получении состояния разрешений: $e");
          return [];
        }
      }
    } else {
      if (kDebugMode) {
        print('getPermissionsState skipped: Not Android platform');
      }
    }
    return [];
  }

  static Future<int> getNumberOfNetworkMembers() async {
    return await _InvokePlatformMethods._invokeMethod<int>(
      platformMethods,
      'getNumberOfNetworkMembers',
      onDefaultErrorResult: () => 0,
    ) ?? 0;
  }

  static Future<SendResult> sendMessage(String message) async {
    return SendResult.fromChannelValue(
      await _InvokePlatformMethods._invokeMethod<String?>(
        platformMethods,
        'sendMessage',
        args: message,
        onDefaultErrorResult: () => SendResult.notImplemented.name,
      ) ?? SendResult.notImplemented.name,
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
        print('Subscription to listen ${eventName ?? 'event'} skipped: Not Android platform');
      }
      return Stream<T>.empty();
    }

    return eventChannel.receiveBroadcastStream().cast<T>();
  }
}

