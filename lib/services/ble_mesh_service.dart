import 'dart:typed_data';

import 'package:flutter/foundation.dart'
    show kDebugMode, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/services.dart'
    show MethodChannel, PlatformException, MissingPluginException;

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
  static const platform = MethodChannel('ru.yzhjdjq.ats.platform_methods');

  static final bool _isAndroid =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

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
          ? await platform.invokeMethod<T>(method, args)
          : await platform.invokeMethod<T>(method);
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
        ) ??
        false;
  }

  static Future<List<PermissionInfo>> getPermissionsState() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final result = await platform.invokeMethod<Map<dynamic, dynamic>>(
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

  static Future<SendResult> sendMessage() async {
    return SendResult.fromChannelValue(
      await _invokeMethod<String?>(
            'sendMessage',
            onDefaultErrorResult: () => SendResult.notImplemented.name,
          ) ??
          SendResult.notImplemented.name,
    );
  }

  static Future<SendResult> sendMessageWithPayload(
    // String recipientId,
    // Uint8List bytes,
  ) async {
    return SendResult.fromChannelValue(
      await _invokeMethod<String?>(
            'sendRawBytes',
            args: Message(len: 3, recipientId: 'recipientId', payload: Uint8List.fromList([0x123456])).toJson(),
            onDefaultErrorResult: () => SendResult.notImplemented.name,
          ) ??
          SendResult.notImplemented.name,
    );
  }
}
