import 'package:flutter/foundation.dart' show ChangeNotifier;

/// Миксин для провайдеров с паттерном Singleton.
///
/// Для использования добавьте его через `with SingletonMixin` и реализуйте конструктор `_internal()`
/// в качестве примера можно обратиться к UserProvider и LoginPageProvider.
mixin SingletonMixin on ChangeNotifier {
  static final Map<Type, ChangeNotifier> _instances = {};

  /// Получение экземпляра провайдера
  static T getInstance<T extends ChangeNotifier>() {
    final instance = _instances[T];
    if (instance == null) {
      throw Exception('$T is not initialized. Call initialize() first.');
    }
    return instance as T;
  }

  /// Проверка инициализации провайдера по типу
  static bool isInitialized<T extends ChangeNotifier>() {
    return _instances.containsKey(T);
  }

  /// Регистрация экземпляра (используется внутри initialize)
  static void registerInstance<T extends ChangeNotifier>(T instance) {
    _instances[T] = instance;
  }
}
