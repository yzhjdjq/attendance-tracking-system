import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:ats/models/models.dart' show User;
import 'package:ats/providers/providers.dart' show SingletonMixin;
import 'package:ats/repositories/repositories.dart' show UserRepository;

class UserProvider with ChangeNotifier, SingletonMixin {
  static UserProvider get instance {
    return SingletonMixin.getInstance<UserProvider>();
  }

  static Future<UserProvider> initialize() async {
    if (SingletonMixin.isInitialized<UserProvider>()) {
      return instance;
    }

    final provider = UserProvider._internal();
    await provider._loadDataFromRepository();
    return provider;
  }

  UserProvider._internal() {
    SingletonMixin.registerInstance(this);
  }

  static bool get isInitialized => SingletonMixin.isInitialized<UserProvider>();

  final UserRepository _userRepo = UserRepository();
  static User _user = const User(isAuthenticated: false, username: null, accessToken: null);

  Future<void> _loadDataFromRepository() async {
    _user = await _userRepo.load(defaultValue: _user);
  }

  void _saveDataToRepository() async {
    await _userRepo.save(_user);
    notifyListeners();
  }

  bool get isAuthenticated => _user.isAuthenticated;

  String get username => _user.username ?? '';

  void authenticate(String login, String password) async {
    _user = User(isAuthenticated: true, username: login);
    _saveDataToRepository();
  }

  void logout() async {
    _user = const User(isAuthenticated: false, username: null, accessToken: null);
    _saveDataToRepository();
  }
}
