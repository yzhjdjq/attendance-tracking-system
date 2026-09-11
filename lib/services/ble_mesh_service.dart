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
  static const platformMethodsInit = MethodChannel('ru.yzhjdjq.ats.platform_methods/init');
  static const EventChannel _eventChannelReceiveMessage = EventChannel('ru.yzhjdjq.ats.platform_events/receive_message');
  static Stream<dynamic>? _eventStream;

  static final bool _isAndroid =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Stream<dynamic> get events {
    if (!_isAndroid) {
      if (kDebugMode) {
        print('Subscription to listen to received messages skipped: Not Android platform');
      }
      return Stream.empty();
    }

    _eventStream ??= _eventChannelReceiveMessage.receiveBroadcastStream();
    return _eventStream!;
  }

  static Future<T?> _invokeMethod<T>(
    String method, {
    dynamic args,
    T Function(T? result)? onSuccess,
    T Function()? onDefaultErrorResult,
    T Function()? onNotImplemented,
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
          ? await platformMethods.invokeMethod<T>(method, args)
          : await platformMethods.invokeMethod<T>(method);
      return onSuccess?.call(result) ?? result;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('PlatformException in $method: ${e.message}');
      }
      return onError?.call(e) ?? onDefaultErrorResult as T;
    } on MissingPluginException catch (e) {
      if (kDebugMode) {
        print('MissingPluginException in $method: ${e.message}');
      }
      return onMissingPlugin?.call(e) ?? onDefaultErrorResult as T;
    } catch (e) {
      if (kDebugMode) {
        print('Unknown error in $method: $e');
      }
      return onUnknownError?.call(e) ?? onDefaultErrorResult as T;
    }
  }

  static Future<bool> isImplemented() async {
    return await _invokeMethod<bool>(
      'isImplemented',
      onDefaultErrorResult: () => false,
    ) ?? false;
  }

  static Future<void> initMeshService(String userId) async {
    if (!_isAndroid) {
      if (kDebugMode) {
        print('Method init skipped: Not Android platform');
      }
    }

    try {
      await platformMethodsInit.invokeMethod<void>('init', userId);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('PlatformException in init: ${e.message}');
      }
    } on MissingPluginException catch (e) {
      if (kDebugMode) {
        print('MissingPluginException in init: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unknown error in init: $e');
      }
    }
  }

  static Future<void> setUserId(String? userId) async {
    await _invokeMethod<void>(
      'setUserId',
      args: userId ?? 'empty',
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
    return await _invokeMethod<int>(
      'getNumberOfNetworkMembers',
      onDefaultErrorResult: () => 0,
    ) ?? 0;
  }

  static Future<SendResult> sendMessage(String message) async {
    return SendResult.fromChannelValue(
      await _invokeMethod<String?>(
        'sendMessage',
        args: message,
        onDefaultErrorResult: () => SendResult.notImplemented.name,
      ) ?? SendResult.notImplemented.name,
    );
  }
}
