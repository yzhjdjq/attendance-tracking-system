import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:ats/providers/singleton_provider.dart' show SingletonMixin;
import 'package:ats/providers/model_providers/model_providers.dart' show UserProvider;

class LoginPageProvider with ChangeNotifier, SingletonMixin {
  static LoginPageProvider get instance {
    return SingletonMixin.getInstance<LoginPageProvider>();
  }

  static Future<LoginPageProvider> initialize({required UserProvider userProvider}) async {
    if (SingletonMixin.isInitialized<LoginPageProvider>()) {
      return instance;
    }

    final provider = LoginPageProvider._internal(userProvider);
    return provider;
  }

  LoginPageProvider._internal(this._userProvider) {
    SingletonMixin.registerInstance(this);

    _userProvider.addListener(notify);
  }

  static bool get isInitialized => SingletonMixin.isInitialized<LoginPageProvider>();

  late final UserProvider _userProvider;

  void notify() => notifyListeners();

  void authorize(String login, String password) {
    _userProvider.authenticate(login, password);
  }
}
