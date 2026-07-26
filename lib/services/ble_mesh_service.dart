import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/services.dart' show MethodChannel, PlatformException, MissingPluginException;

enum SendResult {
  notImplemented,
  success,
  error;

  static SendResult fromChannelValue(String value) {
    return SendResult.values.firstWhere(
          (e) => e.name == value.toLowerCase(),
      orElse: () => SendResult.notImplemented,
    );
  }
}

class BleMeshService {
  static const platform = MethodChannel('ru.yzhjdjq.ats.platform_methods');

  static Future<SendResult> sendMessage() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final result = await platform.invokeMethod('sendMessage');
        return SendResult.fromChannelValue(result);
      } on PlatformException catch (e) {
        if (kDebugMode) {
          print("Ошибка при отправке сообщения: $e");
          return SendResult.error;
        }
      } on MissingPluginException catch (e) {
        if (kDebugMode) {
          print("BLE Mesh ядро не реализовано: ${e.message}");
          return SendResult.notImplemented;
        }
      } catch (e) {
        if (kDebugMode) {
          print("Неизвестная ошибка при отправке сообщения: $e");
          return SendResult.error;
        }
      }
    } else {
      if (kDebugMode) {
        print('Widget update skipped: Not Android platform');
        return SendResult.notImplemented;
      }
    }
    return SendResult.notImplemented;
  }
}