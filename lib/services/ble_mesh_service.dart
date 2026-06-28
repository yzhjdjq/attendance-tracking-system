import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/services.dart' show MethodChannel, PlatformException, MissingPluginException;

enum SendResult {
  notImplemented,
  success,
  error
}

class BleMeshService {
  static const platform = MethodChannel('ru.yzhjdjq.ats.platform_methods');

  static Future<SendResult> sendMessage() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        return await platform.invokeMethod('performPlatformOperation');
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